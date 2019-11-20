if Rails.env.development?
  require 'active_record_query_trace'
  ActiveRecordQueryTrace.enabled = true
  ActiveRecordQueryTrace.level = :custom
  ActiveRecordQueryTrace.backtrace_cleaner = ->(trace) do
    trace.reject do |line|
      line =~ /\b(active_record_query_trace|active_support|action_view|active_record|rack-mini-profiler)\b/
    end
  end
end
