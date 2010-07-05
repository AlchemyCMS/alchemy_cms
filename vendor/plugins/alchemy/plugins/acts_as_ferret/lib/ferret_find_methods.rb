module ActsAsFerret
  # Ferret search logic common to single-class indexes, shared indexes and
  # multi indexes.
  module FerretFindMethods

    def find_records(q, options = {}, ar_options = {})
      late_pagination = options.delete :late_pagination
      total_hits, result = if options[:lazy]
        logger.warn "find_options #{ar_options} are ignored because :lazy => true" unless ar_options.empty?
        lazy_find q, options
      else
        ar_find q, options, ar_options
      end
      if late_pagination
        limit = late_pagination[:limit]
        offset = late_pagination[:offset] || 0
        end_index = limit == :all ? -1 : limit+offset-1
        # puts "late pagination: #{offset} : #{end_index}"
        result = result[offset..end_index]
      end
      return [total_hits, result]
    end

    def lazy_find(q, options = {})
      logger.debug "lazy_find: #{q}"
      result = []
      rank   = 0
      total_hits = find_ids(q, options) do |model, id, score, data|
        logger.debug "model: #{model}, id: #{id}, data: #{data}"
        result << FerretResult.new(model, id, score, rank += 1, data)
      end
      [ total_hits, result ]
    end

    def ar_find(q, options = {}, ar_options = {})
      ferret_options = options.dup
      if ar_options[:conditions] or ar_options[:order]
        ferret_options[:limit] = :all
        ferret_options.delete :offset
      end
      total_hits, id_arrays = find_id_model_arrays q, ferret_options
      logger.debug "now retrieving records from AR with options: #{ar_options.inspect}"
      result = ActsAsFerret::retrieve_records(id_arrays, ar_options)
      logger.debug "#{result.size} results from AR: #{result.inspect}"
      
      # count total_hits via sql when using conditions, multiple models, or when we're called
      # from an ActiveRecord association.
      if id_arrays.size > 1 or ar_options[:conditions]
        # chances are the ferret result count is not our total_hits value, so
        # we correct this here.
        if options[:limit] != :all || options[:page] || options[:offset] || ar_options[:limit] || ar_options[:offset]
          # our ferret result has been limited, so we need to re-run that
          # search to get the full result set from ferret.
          new_th, id_arrays = find_id_model_arrays( q, options.merge(:limit => :all, :offset => 0) )
          # Now ask the database for the total size of the final result set.
          total_hits = count_records( id_arrays, ar_options )
        else
          # what we got from the database is our full result set, so take
          # it's size
          total_hits = result.length
        end
      end
      [ total_hits, result ]
    end

    def count_records(id_arrays, ar_options = {})
      count_options = ar_options.dup
      count_options.delete :limit
      count_options.delete :offset
      count_options.delete :order
      count_options.delete :select
      count = 0
      id_arrays.each do |model, id_array|
        next if id_array.empty?
        model = model.constantize
        # merge conditions
        conditions = ActsAsFerret::conditions_for_model model, ar_options[:conditions]
        count_options[:conditions] = ActsAsFerret::combine_conditions([ "#{model.table_name}.#{model.primary_key} in (?)", id_array.keys ], conditions)
        count_options[:include] = ActsAsFerret::filter_include_list_for_model(model, ar_options[:include]) if ar_options[:include]
        cnt = model.count count_options
        if cnt.is_a?(ActiveSupport::OrderedHash) # fixes #227
          count += cnt.size
        else
          count += cnt
        end
      end
      count
    end

    def find_id_model_arrays(q, options)
      id_arrays = {}
      rank = 0
      total_hits = find_ids(q, options) do |model, id, score, data|
        id_arrays[model] ||= {}
        id_arrays[model][id] = [ rank += 1, score ]
      end
      [total_hits, id_arrays]
    end

    # Queries the Ferret index to retrieve model class, id, score and the
    # values of any fields stored in the index for each hit.
    # If a block is given, these are yielded and the number of total hits is
    # returned. Otherwise [total_hits, result_array] is returned.
    def find_ids(query, options = {})

      result = []
      stored_fields = determine_stored_fields options

      q = process_query(query, options)
      q = scope_query_to_models q, options[:models] #if shared?
      logger.debug "query: #{query}\n-->#{q}"
      s = searcher
      total_hits = s.search_each(q, options) do |hit, score|
        doc = s[hit]
        model = doc[:class_name]
        # fetch stored fields if lazy loading
        data = extract_stored_fields(doc, stored_fields)
        if block_given?
          yield model, doc[:id], score, data
        else
          result << { :model => model, :id => doc[:id], :score => score, :data => data }
        end
      end
      #logger.debug "id_score_model array: #{result.inspect}"
      return block_given? ? total_hits : [total_hits, result]
    end

    def scope_query_to_models(query, models)
      return query if models.nil? or models == :all
      models = [ models ] if Class === models
      q = Ferret::Search::BooleanQuery.new
      q.add_query(query, :must)
      model_query = Ferret::Search::BooleanQuery.new
      models.each do |model|
        model_query.add_query(Ferret::Search::TermQuery.new(:class_name, model.name), :should)
      end
      q.add_query(model_query, :must)
      return q
    end

  end
end
