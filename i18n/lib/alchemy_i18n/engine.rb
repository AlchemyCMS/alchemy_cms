module AlchemyI18n
  class Engine < ::Rails::Engine
    initializer "alchemy-i18n" do |app|
      locales = Array(app.config.i18n.available_locales).reject { |l| l == :en }
      pattern = locales.empty? ? "*" : "{#{locales.join ","}}"
      files = Dir[root.join("locales", "alchemy.#{pattern}.yml")]
      I18n.load_path.concat(files)
      app.config.assets.paths << AlchemyI18n::Engine.root.join("vendor/locales")
      config.assets.precompile << "alchemy_i18n.js"
      locales.each do |locale|
        Alchemy.importmap.pin "flatpickr/#{locale}.js", to: "flatpickr/#{locale}.js"
        Alchemy.importmap.pin "select2/#{locale}.js", to: "select2_locale_#{locale}.js"
        Alchemy.admin_js_imports << "flatpickr/#{locale}.js"
        Alchemy.admin_js_imports << "select2/#{locale}.js"
      end
    end
  end
end
