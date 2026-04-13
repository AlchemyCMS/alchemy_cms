# AlchemyCMS Translations

Translation files for [AlchemyCMS](https://github.com/AlchemyCMS/alchemy_cms) 8.0 and above.

## Alchemy version

| Alchemy CMS | alchemy_i18n | Branch        |
|-------------|-------------|---------------|
| 8.2         | >= 8.2.0    | `8.2-stable`  |
| 8.0         | 5.x         | `5.1-stable`  |
| 7.x         | 4.3.x       | `4.3-stable`  |
| 7.0         | 4.0.x       | `4.0-stable`  |
| 6.1         | 3.2.x       | `3.2-stable`  |
| 5.3         | 2.3.x       | `2.3-stable`  |

## Installation

Add the gem to your `Gemfile` and run the install generator:

```
bundle add alchemy_i18n
bin/rails g alchemy_i18n:install
```

Pass the locales you want to generate files for with the `--locales` option.
Separate multiple locales by space.

```
bin/rails g alchemy_i18n:install --locales de it es
```

## Available locales

`de` `es` `fr` `it` `nb-NO` `nl` `pl` `ru` `zh-CN`

### Noteworthy missing translations

Russian (`ru`) and Chinese (`zh-CN`) are at roughly 68% coverage and need help.

## Contributing

1. Fork the repository
2. Add or update translations in the locale files under `locales/`
3. Open a pull request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
