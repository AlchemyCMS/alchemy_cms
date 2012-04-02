namespace :alchemy do

  namespace :db do

    desc "Seeds the database with essential data for Alchemy."
    task :seed => :environment do
      Alchemy::Seeder.seed!
    end

  end

  namespace :standard_set do

    desc "Install Alchemys standard set."
    task :install do
      system("rails g alchemy:scaffold --with-standard-set")
    end

  end

end
