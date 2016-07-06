begin
  require 'sassc-rails'
rescue LoadError, Gem::LoadError
  begin
    require 'sass-rails'
  rescue LoadError, Gem::LoadError
    raise LoadError, "Could not find the `sass-rails` or `sassc-rails` gem for AlchemyCMS! Please add one of them to your project's Gemfile."
  end
end
