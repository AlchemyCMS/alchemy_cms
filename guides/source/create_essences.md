Creating own Essences
---------------------

Alchemys powerful content storage technology is build around Essences.
They are ActiveRecord models that have an editor and a presentation view
partial.

Alchemy has lots of build in essences. But you can create your own
essence and even associate them with your existing models. This guide
shows how.

-   Use the generator to create a new essence
-   Associate an essence to your model

endprologue.

### Using The Essence Generator

The essence generator is a wrapper around the rails model generator. It
generates the essence model for you and injects the
<code>acts\_as\_essence</code> class method.

<shell>\
 rails g alchemy:essence Alchemy::EssenceHeadline\
</shell>

INFO: Essences are typically created under the Alchemy namespace. The
naming convention is EssenceYourName.

This is what the generated model looks like:

<ruby>

1.  app/models/alchemy/essence\_headline.rb\
    class Alchemy::EssenceHeadline \< ActiveRecord::Base\
     acts\_as\_essence\
    end\
    </ruby>

Alchemy makes some consumptions about your essence. First of all it
looks for a <code>body</code> column that it uses as
<code>ingredient</code> column.

If you want to store the value in another column, please use one of [the
various
options](http://rubydoc.info/github/magiclabs/alchemy_cms/Alchemy/Essence/ClassMethods:acts_as_essence)
the <code>acts\_as\_essence</code> class method provides.

### The essence views

Every essence has to have two views:

-   One for presenting
-   One for editing

#### The view partial

The view partial is used by the <code>render\_elements</code> helper to
present the essence to the user.

It is yours. Adjust it to your needs. You can access the value with the
<code>ingredient</code> method of the <code>content</code> object
instance.

<erb>

<!-- app/views/alchemy/essences/_essence_headline_view.html.erb -->
<h1>
\<= content.ingredient\></h1>\
</erb>

#### The editor partial

The editor partial is basically a set of form fields holding values of
your essence. It is rendered inside the element editor view form object.

This is just what the generator creates for you:

<erb>

<!-- app/views/alchemy/essences/_essence_headline_editor.html.erb -->
\<% cache(content) do %\>

<div class="essence_headline content_editor" id="<%= content.dom_id %>
"\>\
 \<= label\_and\_remove\_link(content)\>\
 \<%= text\_field\_tag(\
 content.form\_field\_name,\
 content.ingredient,\
 :id =\> content.form\_field\_id\
 ) %\>

</div>
\<% end %\>\
</erb>

But this is yours. Feel free to adjust it to your needs.\
Just make shure that you provide form fields that Alchemy can use to
update your object in the database.

### Associations

You can associate every ActiveRecord based model with an essence. In
this example we want to connect an existing <code>Product</code> model
to an element, so we can associate it with an Alchemy page.

Just use the ingredient\_column option to tell Alchemy the foreign key
to use for the association.

#### Set the foreign key

<ruby>

1.  app/models/alchemy/essence\_product.rb\
    class Alchemy::EssencePerson \< ActiveRecord::Base\
     acts\_as\_essence ingredient\_column: ‘person\_id’\
    end\
    </ruby>

#### Accessing your model instance

That’s it. Everything else is handled by Alchemy. You can now access the
associated <code>Person</code> model with the <code>ingredient</code>
method on an instance of the <code>Alchemy::Content</code>.

<erb>

<!-- app/views/alchemy/essences/_essence_person_view.html.erb -->
\<= content.ingredient.firstname\>\
</erb>

Now you can use your new essence in any element you want. Connect it
like shown in the [Elements guide](elements.html).\
 
