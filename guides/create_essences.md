# Creating own Essences

Alchemys powerful content storage technology is build around Essences. They are ActiveRecord models that have an editor and a presentation view partial.

Alchemy has lots of build in essences. But you can create your own essence and even associate them with your existing models. This guide shows how.

* Use the generator to create a new essence
* Associate an essence to your model

## Using The Essence Generator

The essence generator is a wrapper around the rails model generator. It generates the essence model for you and injects the `acts_as_essence` class method.

~~~ bash
bin/rails g alchemy:essence Alchemy::EssenceHeadline
~~~

::: tip INFO
Essences are typically created under the Alchemy namespace. The naming convention is EssenceYourName
:::

This is what the generated model looks like:

~~~ ruby
# app/models/alchemy/essence_headline.rb
class Alchemy::EssenceHeadline < ActiveRecord::Base
  acts_as_essence
end
~~~

Alchemy makes some assumptions about your essence. First of all it looks for a `body` column that it uses as `ingredient` column.

If you want to store the value in another column, please use one of [the various options](http://rubydoc.info/github/AlchemyCMS/alchemy_cms/Alchemy/Essence/ClassMethods:acts_as_essence) the `acts_as_essence` class method provides.

## The essence views

Every essence has to have two views:

* One for presenting
* One for editing

### The view partial

The view partial is used by the `render_elements` helper to present the essence to the user.

It is yours. Adjust it to your needs. You can access the value with the `ingredient` method of the `content` object instance.

~~~ erb
<!-- app/views/alchemy/essences/_essence_headline_view.html.erb -->
<h1><%= content.ingredient %></h1>
~~~

### The editor partial

The editor partial is basically a set of form fields holding values of your essence. It is rendered inside the element editor view form object.

This is just what the generator creates for you:

~~~ erb
<!-- app/views/alchemy/essences/_essence_headline_editor.html.erb -->
<% cache(content) do %>
  <div class="essence_headline content_editor" id="<%= content.dom_id %>">
    <%= label_and_remove_link(content) %>
    <%= text_field_tag(
      content.form_field_name,
      content.ingredient,
      :id => content.form_field_id
    ) %>
  </div>
<% end %>
~~~

But this is yours. Feel free to adjust it to your needs.
Just make shure that you provide form fields that Alchemy can use to update your object in the database.

## Associations

You can associate every ActiveRecord based model with an essence. In this example we want to connect an existing `Person` model to an element, so we can associate it with an Alchemy page.

Just use the ingredient_column option to tell Alchemy the foreign key to use for the association.

### Set the foreign key

~~~ ruby
# app/models/alchemy/essence_person.rb
class Alchemy::EssencePerson < ActiveRecord::Base
  acts_as_essence ingredient_column: 'person_id'
end
~~~

## Accessing your model instance

That's it. Everything else is handled by Alchemy. You can now access the associated `Person` model with the `ingredient` method on an instance of the `Alchemy::Content`.

~~~ erb
<!-- app/views/alchemy/essences/_essence_person_view.html.erb -->
<%= content.ingredient.firstname %>
~~~

Now you can use your new essence in any element you want. Connect it like shown in the [Elements guide](elements.html).
