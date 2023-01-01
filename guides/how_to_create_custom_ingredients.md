# Creating own Ingredients

Alchemys powerful content storage technology is build around ingredients. They are ActiveRecord models that have an editor and a presentation view partial.

Alchemy has lots of [build in ingredients](https://github.com/AlchemyCMS/alchemy_cms/tree/main/app/models/alchemy/ingredients). But you can create your own ingredient and even associate them with your existing models. This guide shows how.

* Use the generator to create a new ingredient
* Associate an ingredient to your model

## Using The Ingredient Generator

The ingredient generator is a wrapper around the Rails model generator. It generates the ingredient model for you.

~~~ bash
bin/rails g alchemy:ingredient MyIngredient
~~~

::: tip INFO
Ingredients are created under the `Alchemy::Ingredients` namespace.
:::

This is what the generated model looks like:

~~~ ruby
# app/models/alchemy/ingredients/my_ingredient.rb
module Alchemy
  module Ingredients
    class MyIngredient < Alchemy::Ingredient
      # Set additional attributes that get stored in the `data` JSON column
      # store_accessor :data, :some, :attribute

      # Set a related_object alias for convenience
      # related_object_alias :some_association_name, class_name: "Some::Klass"
    end
  end
end
~~~

Alchemy stores the main value in the `value` (a `Text`) column.

If you want to store additional values in another column, please add it as attribute to the `data` [`store_accessor`](https://api.rubyonrails.org/classes/ActiveRecord/Store.html). Rails will create accessor methods for you.

## The ingredient views

Every ingredient has to have two views:

* One for presenting
* One for editing

### The view partial

The view partial is used by the `render_elements` helper to present the ingredient to the user.

It is yours. Adjust it to your needs. You can access the value with the `ingredient` method of the `content` object instance.

~~~ erb
<!-- app/views/alchemy/ingredients/_my_ingredient_view.html.erb -->
<h1><%= my_ingredient_view.ingredient %></h1>
~~~

### The editor partial

The editor partial is basically a set of form fields holding values of your ingredient. It is rendered inside the element editor view form object.

This is just what the generator creates for you:

~~~ erb
<!-- app/views/alchemy/ingredients/_my_ingredient_editor.html.erb -->
<%= content_tag :div,
  class: my_ingredient_editor.css_classes,
  data: my_ingredient_editor.data_attributes do %>
  <%= element_form.fields_for(:ingredients, my_ingredient_editor.ingredient) do |f| %>
    <%= ingredient_label(my_ingredient_editor) %>
    <%= f.text_field :value %>
  <% end %>
<% end %>
~~~

But this is yours. Feel free to adjust it to your needs.
Just make shure that you provide form fields that Alchemy can use to update your object in the database.

## Associations

You can associate every ActiveRecord based model with an ingredient. In this example we want to connect an existing `Person` model to an element, so we can associate it with an Alchemy page.

Just use the `related_object_alias` method to tell Alchemy the foreign key to use for the association.

### Set the foreign key

~~~ ruby
# app/models/alchemy/ingredients/person.rb
module Alchemy
  module Ingredients
    class Person < Alchemy::Ingredient
      related_object_alias :person, class_name: "My::Person"
    end
  end
end
~~~

### Accessing your model instance

That's it. Everything else is handled by Alchemy. You can now access the associated `My::Person` model with the `person` method.

~~~ erb
<!-- app/views/alchemy/ingredients/_person_view.html.erb -->
<%= person_view.person.firstname %>
~~~

Now you can use your new ingredient in any element you want as shown in the [Elements guide](elements).
