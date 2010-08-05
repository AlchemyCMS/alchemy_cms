Simple [FastGettext](http://github.com/grosser/fast_gettext) / Rails integration.

Do all translations you want with FastGettext, use any other I18n backend as extension/fallback.

Rails does: `I18n.t('weir.rails.syntax.i.hate')`  
We do: `_('Just translate my damn text!')`  
To use I18n calls define a `weir.rails.syntax.i.hate` translation.  

[See it working in the example application.](https://github.com/grosser/gettext_i18n_rails_example)

Setup
=====
###Installation
This plugin: `  script/plugin install git://github.com/grosser/gettext_i18n_rails.git  `

[FastGettext](http://github.com/grosser/fast_gettext): `  sudo gem install fast_gettext  `

### Want to find used messages in your ruby files ?
GetText 1.93 or GetText 2.0: `  sudo gem install gettext  `  
GetText 2.0 will render 1.93 unusable, so only install if you do not have apps that use 1.93!

`  sudo gem install ruby_parser  `

### Locales & initialisation
Copy default locales with dates/sentence-connectors/AR-errors you want from e.g.
[rails i18n](http://github.com/svenfuchs/rails-i18n/tree/master/rails/locale/) into 'config/locales'

    #environment.rb
    Rails::Initializer.run do |config|
      ...
      config.gem "fast_gettext", :version => '~>0.4.17'
      #only used for mo/po file generation in development, !do not load(:lib=>false), will needlessly eat ram!
      config.gem "gettext", :lib => false, :version => '>=1.9.3'
    end

    #config/initialisers/fast_gettext.rb
    FastGettext.add_text_domain 'app', :path => 'locale'

    #application_controller
    class ApplicationController < ...
      before_filter :set_gettext_locale
      def set_gettext_locale
        FastGettext.text_domain = 'app'
        FastGettext.available_locales = ['en','de'] #all you want to allow
        super
      end

Translating
===========
###Getting started
####Option A: Traditional mo/po files
 - use some _('translations')
 - run `rake gettext:find`, to let GetText find all translations used
 - (optional) run `rake gettext:store_model_attributes`, to parse the database for columns that can be translated
 - if this is your first translation: `cp locale/app.pot locale/de/app.po` for every locale you want to use
 - translate messages in 'locale/de/app.po' (leave msgstr blank and msgstr == msgid)  
new translations will be marked "fuzzy", search for this and remove it, so that they will be used.
Obsolete translations are marked with ~#, they usually can be removed since they are no longer needed
 - run `rake gettext:pack` to write GetText format translation files

####Option B: Database
This is the most scalable method, since all translators can work simultanousely and online.

Most easy to use with the [translation database Rails engine](http://github.com/grosser/translation_db_engine).
FastGettext setup would look like:
    include FastGettext::TranslationRepository::Db.require_models #load and include default models
    FastGettext.add_text_domain 'app', :type=>:db, :model=>TranslationKey
Translations can be edited under `/translation_keys`

###I18n

    I18n.locale <==> FastGettext.locale.to_sym
    I18n.locale = :de <==> FastGettext.locale = 'de'

Any call to I18n that matches a gettext key will be translated through FastGettext.

Namespaces
==========
Car|Model means Model in namespace Car.  
You do not have to translate this into english "Model", if you use the
namespace-aware translation
    s_('Car|Model') == 'Model' #when no translation was found

ActiveRecord - error messages
=============================
ActiveRecord error messages are translated through Rails::I18n, but
model names and model attributes are translated through FastGettext.
Therefore a validation error on a BigCar's wheels_size needs `_('big car')` and `_('BigCar|Wheels size')`
to display localized.

The model/attribute translations can be found through `rake gettext:store_model_attributes`,
(which ignores some commonly untranslated columns like id,type,xxx_count,...).

Error messages can be translated through FastGettext, if the ':message' is a translation-id or the matching Rails I18n key is translated.
In any other case they go through the SimpleBackend.

####Option A:
Define a translation for "I need my rating!" and use it as message.
    validates_inclusion_of :rating, :in=>1..5, :message=>N_('I need my rating!')

####Option B:
Do not use :message
    validates_inclusion_of :rating, :in=>1..5
and make a translation for the I18n key: `activerecord.errors.models.rating.attributes.rating.inclusion`

####Option C:
Add a translation to each config/locales/*.yml files
    en:
      activerecord:
        errors:
          models:
            rating:
              attributes:
                rating:
                  inclusion: " -- please choose!"
The [rails I18n guide](http://guides.rubyonrails.org/i18n.html) can help with Option B and C.

Plurals
=======
FastGettext supports pluralization
    n_('Apple','Apples',3) == 'Apples'

Unfound translations
====================
Sometimes translations like `_("x"+"u")` cannot be fond. You have 4 options:

 - add `N_('xu')` somewhere else in the code, so the parser sees it
 - add `N_('xu')` in a totally seperate file like `locale/unfound_translations.rb`, so the parser sees it
 - use the [gettext_test_log rails plugin ](http://github.com/grosser/gettext_test_log) to find all translations that where used while testing
 - add a Logger to a translation Chain, so every unfound translations is logged ([example]((http://github.com/grosser/fast_gettext)))


Author
======
 - [ruby gettext extractor](http://github.com/retoo/ruby_gettext_extractor/tree/master) from [retoo](http://github.com/retoo)

[Michael Grosser](http://pragmatig.wordpress.com)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...  
