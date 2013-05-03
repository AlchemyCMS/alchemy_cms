namespace :ferret do

  desc "Updates the ferret index for the application."
  task :rebuild_index => :environment do
    abort 'Enable ferret search in Alchemy config first.' if !Alchemy::Config.get(:ferret)
    if Alchemy::EssenceText.rebuild_index
      puts "Rebuilding Ferret Index for EssenceText"
    end
    if Alchemy::EssenceRichtext.rebuild_index
      puts "Rebuilding Ferret Index for EssenceRichtext"
    end
    puts "Completed Ferret Index Rebuild"
  end

end
