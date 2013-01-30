namespace :ferret do

  desc "Updates the Ferret index."
  task :rebuild_index => :environment do
    Alchemy::EssenceText.where(:do_not_index => false).rebuild_index
    Alchemy::EssenceRichtext.where(:do_not_index => false).rebuild_index
  end

end
