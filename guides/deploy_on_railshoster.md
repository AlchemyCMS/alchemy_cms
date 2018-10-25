# Railshoster deployment

[RailsHoster](http://www.railshoster.com) offers durable rails hosting for good money. In this guide you will learn how to deploy your Alchemy Site on your RailsHoster server. Please be sure that you have read the "Getting Started Guide":/getting_started to be familar with the Alchemy installation steps. After finishing this guide you will know:

* How to initialize your local Alchemy installation so it is ready to be deployed on RailsHoster
* How to deploy changes you've made to your server

## Prerequisites

We assume that you already have ordered a hostingplan on RailsHoster.

If not please go to [railshoster.com](http://www.railshoster.com/web_hosting) and choose a plan that suites your needs.

Alchemy runs with all plans, even the smallest one starting a only € 4,95.

## Install the railshoster gem

~~~ bash
$ gem install railshoster
~~~

## Create a remote git repo

Create a new repository on [GitHub](https://github.com) or, if you have one, into your own Gitolite/Gitosis server or where ever you have your git remote repositories.

::: warning
DO NOT EVER STORE ANY CRITICAL INFORMATIONS, LIKE DATABASE OR SSH PASSWORDS INTO YOUR GIT REPOSITORY, UNLESS YOU HAVE A PRIVATE ONE!

Remember: GitHub repositories from the free plan are open to the public.
:::

### Init your project as git repository

Inside your projects folder enter:

~~~ bash
git init .
~~~

Open the `.gitignore` file in your editor and add:

~~~ bash
index/**/*
uploads/**/*
~~~

::: tip
You can pass `--scm=git` option to the Alchemy installer while creating a new project. That option inits your project as git repository and sets all ignores for you.
:::

### Add the remote repository

#### GitHub Example

~~~ bash
git remote add origin git@github.com:repository-name.git
~~~

#### Repository server with a non standard ssh port

~~~ bash
git remote add origin ssh://git@your-reposerver.de:SSHPORT/repository-name.git
~~~

## Initialize your project for railshoster

~~~ bash
railshoster init -a YOUR_APP_KEY .
~~~

::: tip
You received your app key for your rails app with your order confirmation from railshoster.
:::

## Add Alchemy and Rails 3.1 deploy tasks

Open the `config/deploy.rb` file with an editor and add:

~~~ ruby
require 'alchemy/capistrano'
load 'deploy/assets'
~~~

#### If your repository server has a non standard ssh port

Change

~~~ ruby
set :repository, "git@your-reposerver.de/repository-name.git"
~~~

to

~~~ ruby
set :repository, "ssh://git@your-reposerver.de:SSHPORT/repository-name.git"
~~~

## Commit and push deploy settings

~~~ bash
$ git commit -am 'Added deploy settings'
$ git push origin master
~~~

## Run the setup task

~~~ bash
railshoster deploy:setup
~~~

::: tip
If prompted, enter the mount point of Alchemy to the same you have in your `config/routes.rb` file.
:::

## Make your first cold deploy

~~~ bash
railshoster deploy:cold
~~~

::: tip
Sometimes the ssh-key forwarding does not work. If the deploy script wants you to enter a password for the repository server then something is wrong with the key forwarding. [RailsHoster has a guide](http://help.railshoster.com/kb/getting-started/showcase-deploy-an-alchemy-cms-site-using-the-railshoster-gem) how to fix this in their knowledge base.
:::

## Check the installation

Open a browser and enter the domain the railshoster gem just showed you after succesfull deploy.

::: tip
You can always get your domain via the railshoster gem. Just run `railshoster appurl` while in your sites folder.
:::

## Next steps

Now you can start to customize your Alchemy site.

Just follow one of our [guides](/getting_started.html).

Everytime you have made a change you want to publish onto your server just run:

~~~ bash
railshoster deploy
~~~
