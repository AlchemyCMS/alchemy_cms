module ActsAsFerret

  # mixed into the FerretResult and AR classes calling acts_as_ferret
  module ResultAttributes
    # holds the score this record had when it was found via
    # acts_as_ferret
    attr_accessor :ferret_score

    attr_accessor :ferret_rank
  end

  class FerretResult < ActsAsFerret::BlankSlate
    include ResultAttributes
    attr_accessor :id
    reveal :methods

    def initialize(model, id, score, rank, data = {})
      @model = model.constantize
      @id = id
      @ferret_score = score
      @ferret_rank  = rank
      @data = data
      @use_record = false
    end

    def inspect
      "#<FerretResult wrapper for #{@model} with id #{@id}"
    end

    def method_missing(method, *args, &block)
      if (@ar_record && @use_record) || !@data.has_key?(method)
        to_record.send method, *args, &block
      else
        @data[method]
      end
    end

    def respond_to?(name)
      methods.include?(name.to_s) || @data.has_key?(name.to_sym) || to_record.respond_to?(name)
    end

    def to_record
      unless @ar_record
        @ar_record = @model.find(id)
        @ar_record.ferret_rank  = ferret_rank
        @ar_record.ferret_score = ferret_score
        # don't try to fetch attributes from RDig based records
        @use_record = !@ar_record.class.included_modules.include?(ActsAsFerret::RdigAdapter)
      end
      @ar_record
    end
  end
end
