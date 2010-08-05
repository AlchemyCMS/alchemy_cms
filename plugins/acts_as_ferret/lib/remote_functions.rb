module ActsAsFerret
  module RemoteFunctions

    private

    def yield_results(total_hits, results)
      results.each do |result|
        yield result[:model], result[:id], result[:score], result[:data]
      end
      total_hits
    end


    def handle_drb_error(return_value_in_case_of_error = false)
      yield
    rescue DRb::DRbConnError => e
      logger.error "DRb connection error: #{e}"
      logger.warn e.backtrace.join("\n")
      raise e if ActsAsFerret::raise_drb_errors?
      return_value_in_case_of_error
    end

    alias :old_handle_drb_error :handle_drb_error 
    def handle_drb_error(return_value_in_case_of_error = false)
      handle_drb_restart do
        old_handle_drb_error(return_value_in_case_of_error) { yield }
      end
    end

    def handle_drb_restart
      trys = 1
      begin
        return yield
      rescue ActsAsFerret::IndexNotDefined
        logger.warn "Recovering from ActsAsFerret::IndexNotDefined exception"
        ActsAsFerret::ferret_indexes[index_name] = ActsAsFerret::create_index_instance( index_definition )
        ActsAsFerret::ferret_indexes[index_name].register_class ActsAsFerret::index_using_classes.index(index_name).constantize, {}
        retry if (trys -= 1) > 0
      end
      yield
    end
  end
end
