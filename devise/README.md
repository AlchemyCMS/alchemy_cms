## Devise based authentication for Alchemy 3.0

[![Build Status](https://secure.travis-ci.org/magiclabs/alchemy_devise.png?branch=master)](http://travis-ci.org/magiclabs/alchemy_devise)

Alchemy 3.0 has dropped the authentication from its core. So now it is possibly to bring your own authentication and use it to authorize users in Alchemy.

In order to bring the authentication from Alchemy back into your app (For instance, because you don't have your own user authorization), you can use this gem.

## Install

Just put the gem into your projects `Gemfile`.

~~~
# Gemfile
gem 'alchemy-devise'
~~~

and run `bundle install`.

Migrate the database:

~~~
$ rake alchemy_devise:install:migrations
$ rake db:migrate
~~~

**Thats it \o/**


Getting Help
------------

* If you have bugs, please use the [issue tracker on Github](https://github.com/magiclabs/alchemy-devise/issues).
* For Q&A and general usage, please use the [User Group](http://groups.google.com/group/alchemy-cms) or the IRC channel.
* New features should be discussed on our [Trello Board](https://trello.com/alchemycms). *PLEASE* don't use the Github issues for new features.

Resources
---------

* Homepage: <http://alchemy-cms.com>
* Live-Demo: <http://demo.alchemy-cms.com> (user: demo, password: demo)
* API Documentation: <http://rubydoc.info/github/magiclabs/alchemy_cms>
* Issue-Tracker: <https://github.com/magiclabs/alchemy_cms/issues>
* Sourcecode: <https://github.com/magiclabs/alchemy_cms>
* User Group: <http://groups.google.com/group/alchemy-cms>
* IRC Channel: #alchemy_cms on irc.freenode.net
* Discussion Board: <https://trello.com/alchemycms>

License
-------

* BSD: <https://github.com/magiclabs/alchemy-devise/LICENSE>
