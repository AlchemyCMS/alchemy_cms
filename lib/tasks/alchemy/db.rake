# frozen_string_literal: true

require "alchemy/seeder"

namespace :alchemy do
  namespace :db do
    desc "Seeds the database with Alchemy defaults"
    task seed: [:environment] do
      Alchemy::Seeder.seed!
    end
  end
end
