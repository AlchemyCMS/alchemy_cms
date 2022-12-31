---
prev: configuration
next: false
---

# Upgrading AlchemyCMS

This guide describes how to upgrade AlchemyCMS to a new version.

Upgrading Alchemy is mostly three steps.

1. Update the gem
2. Run the upgrade task
3. Follow ups

## Update the gem

If you use Alchemy from a git branch, point it to the next stable release.

~~~diff
...
-gem 'alchemy_cms', github: 'AlchemyCMS/alchemy_cms', branch: '4.5-stable'
+gem 'alchemy_cms', github: 'AlchemyCMS/alchemy_cms', branch: '4.6-stable'
...
~~~

If you use Alchemy from rubygems, point it to the next stable release.

~~~diff
...
-gem 'alchemy_cms', '~> 4.5'
+gem 'alchemy_cms', '~> 4.6'
...
~~~

If you are using `alchemy-devise` for authentication, then update the gem as well. The major and minor versions of the `alchemy_cms` and the `alchemy-devise` gems match.

~~~diff
...
-gem 'alchemy_cms', '~> 4.5'
+gem 'alchemy_cms', '~> 4.6'
-gem 'alchemy-devise', '~> 4.5'
+gem 'alchemy-devise', '~> 4.6'
...
~~~

Now update via bundler

~~~bash
bundle update
~~~

## Run the Alchemy Upgrader

Now you can run the upgrade task. While upgrading, you will get informations about the process on your screen.

~~~bash
bin/rake alchemy:upgrade
~~~

and follow the on screen instructions.

### Update the default config

If new configuration options have been introduced you see them in the `config/alchemy/config.yml.defaults` file. Simply copy them over and have a look at the `git diff`. Keep your changes remove or add new keys as necessary.

If you have also `alchemy-devise` installed you need to .

~~~bash
bin/rails g alchemy_devise:install
~~~

## Follow ups

Most of the time the upgrader does all the work for you.  Biut sometimes the upgrade needs some manual work. This will be noted as TODOs at the end of the upgrade task.

Please follow them carefully.

## Finished

Please always verify the upgrade by looking through the `git diff` and running your test suite.
