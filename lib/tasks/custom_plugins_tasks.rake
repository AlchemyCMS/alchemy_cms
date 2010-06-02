Dir.glob(File.dirname(__FILE__) + "/../../vendor/plugins/alchemy/plugins/**/tasks/*.rake").each do |rake_file|
  import rake_file
end