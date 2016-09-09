begin
  require 'rack-mini-profiler'
  Rack::MiniProfiler.config.position = 'right'
  Rack::MiniProfiler.config.start_hidden = true
rescue LoadError
end
