module ActsAsFerret
  class RemoteMultiIndex < MultiIndexBase
    include RemoteFunctions

    def initialize(indexes, options = {})
      @index_names = indexes.map(&:index_name)
      @server = DRbObject.new(nil, ActsAsFerret::remote)
      super
    end

    def find_ids(query, options, &proc)
      total_hits, results = handle_drb_error([0, []]) { @server.multi_find_ids(@index_names, query, options) }
      block_given? ? yield_results(total_hits, results, &proc) : [ total_hits, results ]
    end

    def method_missing(name, *args)
      handle_drb_error { @server.send(:"multi_#{name}", @index_names, *args) }
    end
  end
end
