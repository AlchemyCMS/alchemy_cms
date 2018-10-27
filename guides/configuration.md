---
prev: /render_images.html
next: /upgrading.html
---

# Configuration of AlchemyCMS

Alchemy configuration is done in the `config/alchemy/config.yml` file.

Use

~~~ bash
bin/rake alchemy:install
~~~

or

~~~ bash
bin/rails g alchemy:install
~~~

to generate it.

## The configuration file

Please [have a look into the source code](https://github.com/AlchemyCMS/alchemy_cms/blob/master/config/alchemy/config.yml). The file is pretty well documentated and much more up to date then this guide.

## Environment related configurations

Beside using that one configuration file you also can seperate certain config settings for specific environments.

For example: You want to enforce SSL in production, while in your development environment you don't.

Its easy to achieve by setting up a second configuration file for development which contains nothing but the ssl enforcing setting.

Your apps default config:

~~~
your_app/config/alchemy/config.yml
~~~

Environment specific config:

~~~
your_app/config/alchemy/development.config.yml
~~~

::: tip NOTE
When running your application in development mode both config files get merged, while the environment specific config takes precedence over the default config.
:::
