namespace :ferret do

  desc "Updates the Ferret index."
  task :rebuild_index => :environment do
    puts "Rebuilding Ferret index for EssenceText"
    Alchemy::EssenceText.where(:do_not_index => false).rebuild_index
    puts "Rebuilding Ferret index for EssenceRichtext"
    Alchemy::EssenceRichtext.where(:do_not_index => false).rebuild_index
    puts "Completed Ferret index rebuild"
  end

end
