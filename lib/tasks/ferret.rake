namespace :ferret do

  desc "Updates the ferret index for the application."
  task :rebuild_index => :environment do
    puts "Rebuilding Ferret Index for EssenceText"
    Alchemy::EssenceText.rebuild_index
    puts "Rebuilding Ferret Index for EssenceRichtext"
    Alchemy::EssenceRichtext.rebuild_index
    puts "Completed Ferret Index Rebuild"
  end

end
