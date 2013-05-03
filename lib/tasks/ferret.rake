namespace :ferret do

  desc "Updates the Ferret index."
  task :rebuild_index => :environment do
    abort 'Enable ferret search in Alchemy config first.' if !Alchemy::Config.get(:ferret)
    Alchemy::EssenceText.where(:do_not_index => false).rebuild_index
    Alchemy::EssenceRichtext.where(:do_not_index => false).rebuild_index
  end

end
