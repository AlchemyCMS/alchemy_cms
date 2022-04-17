module AlchemyI18n
  class Engine < ::Rails::Engine
    initializer "alchemy-i18n" do |app|
      locales = Array(app.config.i18n.available_locales)
      pattern = locales.empty? ? "*" : "{#{locales.join ","}}"
      files = Dir[root.join("locales", "alchemy.#{pattern}.yml")]
      I18n.load_path.concat(files)
    end
  end
end
