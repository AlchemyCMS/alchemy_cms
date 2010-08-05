################################################################################
require 'optparse'

################################################################################
$ferret_server_options = {
  'environment' => nil,
  'debug'       => nil,
  'root'        => nil
}

################################################################################
OptionParser.new do |optparser|
  optparser.banner = "Usage: #{File.basename($0)} [options] {start|stop|run}"

  optparser.on('-h', '--help', "This message") do
    puts optparser
    exit
  end
  
  optparser.on('-R', '--root=PATH', 'Set RAILS_ROOT to the given string') do |r|
    $ferret_server_options['root'] = r
  end

  optparser.on('-e', '--environment=NAME', 'Set RAILS_ENV to the given string') do |e|
    $ferret_server_options['environment'] = e
  end

  optparser.on('--debug', 'Include full stack traces on exceptions') do
    $ferret_server_options['debug'] = true
  end

  $ferret_server_action = optparser.permute!(ARGV)
  (puts optparser; exit(1)) unless $ferret_server_action.size == 1

  $ferret_server_action = $ferret_server_action.first
  (puts optparser; exit(1)) unless %w(start stop run).include?($ferret_server_action)
end

################################################################################
begin
  ENV['FERRET_USE_LOCAL_INDEX'] = 'true'
  ENV['RAILS_ENV'] = $ferret_server_options['environment']
  
  # determine RAILS_ROOT unless already set
  RAILS_ROOT = $ferret_server_options['root'] || File.join(File.dirname(__FILE__), *(['..']*4)) unless defined? RAILS_ROOT
  # check if environment.rb is present
  rails_env_file = File.join(RAILS_ROOT, 'config', 'environment')
  raise "Unable to find Rails environment.rb at \n#{rails_env_file}.rb\nPlease use the --root option of ferret_server to point it to your RAILS_ROOT." unless File.exists?(rails_env_file+'.rb')
  # load it
  require rails_env_file

  require 'acts_as_ferret'
  ActsAsFerret::Remote::Server.new.send($ferret_server_action)
rescue Exception => e
  $stderr.puts(e.message)
  $stderr.puts(e.backtrace.join("\n")) if $ferret_server_options['debug']
  exit(1)
end
