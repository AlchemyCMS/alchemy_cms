# AlchemyCMS Translations

Translations files for AlchemyCMS 7.0 and above.

## Alchemy version

- For a Alchemy 6.1 compatible version use v3.2.0 or the `3.2-stable` branch.
- For a Alchemy 5.3 compatible version use v2.3.1 or the `2.3-stable` branch.

## Installation

Add this Gem to your `Gemfile` and run the install generator

```
bundle add alchemy_i18n
bin/rails g alchemy_i18n:install
```

Pass the locales you want to generate files for with the `--locales` option.
Seperate multiple locales by space.

```
bin/rails g alchemy_i18n:install --locales=de it es
```

---

A ruby translation project managed on [Locale](http://www.localeapp.com/) that's open to all!

## Contributing to AlchemyCMS/alchemy_i18n

- Edit the translations directly on the [AlchemyCMS/alchemy_i18n](http://www.localeapp.com/projects/public?search=AlchemyCMS/alchemy_i18n) project on Locale.
- **That's it!**
- The maintainer will then pull translations from the Locale project and push to Github.

Happy translating!

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
