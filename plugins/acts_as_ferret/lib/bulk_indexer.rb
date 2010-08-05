module ActsAsFerret
  class BulkIndexer
    def initialize(args = {})
      @batch_size = args[:batch_size] || 1000
      @logger = args[:logger]
      @model = args[:model]
      @work_done = 0
      @indexed_records = 0
      @total_time = 0.0
      @index = args[:index]
      if args[:reindex]
        @reindex = true
        @model_count  = @model.count.to_f
      else
        @model_count = args[:total]
      end
    end

    def index_records(records, offset)
      batch_time = measure_time {
        docs = []
        records.each { |rec| docs << [rec.to_doc, rec.ferret_analyzer] if rec.ferret_enabled?(true) }
        @index.update_batch(docs)
      }.to_f
      rec_count = records.size
      @indexed_records += rec_count
      @total_time += batch_time
      @work_done = @indexed_records.to_f / @model_count * 100.0 if @model_count > 0
      @logger.debug "took #{batch_time} to index last #{rec_count} records. #{records_waiting} records to go. Avg time per record: #{avg_time_per_record}"
      remaining_time = avg_time_per_record * records_waiting
      @logger.info "#{@reindex ? 're' : 'bulk '}index model #{@model.name} : #{'%.2f' % @work_done}% complete : #{'%.2f' % remaining_time} secs to finish"
    end
    
    def measure_time
      t1 = Time.now
      yield
      Time.now - t1
    end
    
    protected
    
    def avg_time_per_record
      if @indexed_records > 0
        @total_time / @indexed_records
      else
        0
      end
    end
    
    def records_waiting
      @model_count - @indexed_records
    end

  end

end
