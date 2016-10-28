if ENV['PROFILER']
  require 'rack-mini-profiler'
  require 'flamegraph'
  require 'stackprof'
  require 'memory_profiler'
  Rack::MiniProfilerRails.initialize!(Rails.application)
end
