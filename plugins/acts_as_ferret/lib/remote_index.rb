require 'drb'
module ActsAsFerret

  # This index implementation connects to a remote ferret server instance. It
  # basically forwards all calls to the remote server.
  class RemoteIndex < AbstractIndex
    include RemoteFunctions

    def initialize(config)
      super
      @server = DRbObject.new(nil, ActsAsFerret::remote)
    end

    # Cause model classes to be loaded (and indexes get declared) on the DRb
    # side of things.
    def register_class(clazz, options)
      handle_drb_error { @server.register_class clazz.name }
    end

    def method_missing(method_name, *args)
      args.unshift index_name
      handle_drb_error { @server.send(method_name, *args) }
    end

    # Proxy any methods that require special return values in case of errors
    { 
      :highlight => [] 
    }.each do |method_name, default_result|
      define_method method_name do |*args|
        args.unshift index_name
        handle_drb_error(default_result) { @server.send method_name, *args }
      end
    end

    def find_ids(q, options = {}, &proc)
      total_hits, results = handle_drb_error([0, []]) { @server.find_ids(index_name, q, options) }
      block_given? ? yield_results(total_hits, results, &proc) : [ total_hits, results ]
    end

    # add record to index
    def add(record)
      handle_drb_error { @server.add index_name, record.to_doc }
    end
    alias << add

    private

    #def model_class_name
    #  index_definition[:class_name]
    #end

  end

end
