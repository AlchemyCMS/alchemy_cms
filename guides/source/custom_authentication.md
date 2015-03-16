Custom Authentication
---------------------

Alchemy 3.0 has removed its build in authentication into a separate gem
called [alchemy-devise](https://github.com/magiclabs/alchemy-devise).

Now, that this is not in the core anymore it gives you the possibility
to add your own custom authentification. You only have to tell Alchemy
about your user class.

In this guide you will learn to:

-   add just enough code to make your User class work with Alchemy
-   add additionally methods to enhance the integration

endprologue.

### Activating your model

Alchemy has some defaults for user model name and login logout path
names:

#### Defaults

-   <code>Alchemy.user\_class\_name</code> defaults to
    <code>‘User’</code>
-   <code>Alchemy.login\_path</code> defaults to <code>‘/login’</code>
-   <code>Alchemy.logout\_path</code> defaults to <code>‘/logout’</code>

Anyway, you can tell Alchemy about your authentication model
configuration.

##### Example

<ruby>

1.  config/initializers/alchemy.rb\
    Alchemy.user\_class\_name = ‘Admin’\
    Alchemy.login\_path = ‘/auth/login’\
    Alchemy.logout\_path = ‘/auth/logout’\
    </ruby>

### Mandatory methods

#### Setting roles

The only method that Alchemy CMS needs from your user class is
<code>alchemy\_roles</code>.

This method has to return an array of strings containing at least one of
these roles:

-   <code>member</code>
-   <code>author</code>
-   <code>editor</code>
-   <code>admin</code>

##### Example

<ruby>

1.  app/models/user.rb

def alchemy\_roles\
 if admin?\
 %w(admin)\
 else\
 []\
 end\
end\
</ruby>

TIP: You can use your own authorization system to set the role. You only
need to ensure that it returns an Array with at least one of the roles.

That’s it. Alchemy has everything it needs to use your user class as
authentication model.

### Optional methods

Although Alchemy does not need much to know about your user class, there
are some few other attributes that are good to have in your user class
which are:

#### Name

This would be used to say “Welcome back <code>\#{@user.name}</code>” in
the Alchemy dashboard.

##### Example

<ruby>

1.  app/models/user.rb

def name\
 \# If you don’t have a name, you could use the user’s email\
 read\_attribute(:email)\
end\
</ruby>

#### Display name

This is used in the “logged in as” note on the top right corner of the
admin interface.

##### Example

<ruby>

1.  app/models/user.rb

def alchemy\_display\_name\
 \# If you don’t have a name, you could use the user’s email\
 “\#{firstname} \#{lastname}”.strip\
end\
</ruby>

#### Language

A locale String to set the users preferred translation of the Alchemy
GUI.\
Anyway, the user has always the option to switch the language, but it is
good\
to give your user its preferred language.

##### Example

<ruby>

1.  app/models/user.rb

def language\
 \# Always use dutch as translation\
 ‘nl’\
end\
</ruby>

TIP: In a real world application you maybe want to store this as
<code>alchemy\_language</code> in the users table.

#### User stamp columns

Alchemy stores updater and creator ids (if the columns are present).\
If you want to track which user updated a record you need to add:

<code>creator\_id</code> and <code>updater\_id</code>

to your users table.

##### Example

<shell>\
\$ bin/rails g migration add\_creator\_id\_and\_updater\_id\_to\_users
creator\_id:integer:index updater\_id:integer:index\
\$ bin/rake db:migrate\
</shell>

#### Tagging

If you want your users to be taggable you need to add the
<code>acts\_as\_taggable</code> and <code>acts\_as\_tagger</code> class
methods.

##### Example

<ruby>\
class User \< ActiveRecord::Base\
 acts\_as\_taggable\
 acts\_as\_tagger\
 …\
end\
</ruby>

NOTE: You also should add a <code>cached\_tag\_list</code> text column
into your users table for better performance.

<shell>\
\$ bin/rails g migration add\_cached\_tag\_list\_to\_users
cached\_tag\_list:text\
</shell>

This is it! Now your user class should be a first class citizen of the
Alchemy admin backend.
