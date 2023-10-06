module AlchemyI18n
  class Engine < ::Rails::Engine
    initializer "alchemy-i18n" do |app|
      locales = Array(app.config.i18n.available_locales).reject { |l| l == :en }
      pattern = locales.empty? ? "*" : "{#{locales.join ","}}"
      files = Dir[root.join("locales", "alchemy.#{pattern}.yml")]
      I18n.load_path.concat(files)
      locales.each do |locale|
        Alchemy.importmap.pin "flatpickr/#{locale}.js", to: "https://ga.jspm.io/npm:flatpickr@4.6.13/dist/l10n/#{locale}.js"
        Alchemy.admin_js_imports << "flatpickr/#{locale}.js"
      end
    end
  end
end
