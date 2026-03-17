---
prev:
  text: Ingredients
  link: ingredients
---

# Custom Ingredients

Alchemy provides many [built-in ingredient types](ingredients), but you can create your own to store custom data or associate ingredients with your existing models.

Each custom ingredient consists of a model class, a view component for the frontend, and an editor component for the admin interface. Alchemy uses [ViewComponent](https://viewcomponent.org) for both.

::: tip
The [alchemy-solidus](extensions#alchemy-solidus) extension is a good real-world example. It provides `SpreeProduct`, `SpreeTaxon` and `SpreeVariant` ingredient types that associate Alchemy elements with Solidus e-commerce models.
:::

## Using the Generator

The ingredient generator creates the model and both components for you.

~~~ bash
bin/rails g alchemy:ingredient MyIngredient
~~~

This creates three files:

- `app/models/alchemy/ingredients/my_ingredient.rb` - the model
- `app/components/alchemy/ingredients/my_ingredient_view.rb` - the frontend view
- `app/components/alchemy/ingredients/my_ingredient_editor.rb` - the admin editor

::: tip
Ingredients live under the `Alchemy::Ingredients` namespace. The type name in your `elements.yml` is the PascalCase class name, e.g. `MyIngredient`.
:::

## The Model

The generated model extends `Alchemy::Ingredient`. The main content is stored in the `value` column (a `text` column).

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

If you need to store additional values beyond `value`, add them as attributes to the `data` column using [`store_accessor`](https://api.rubyonrails.org/classes/ActiveRecord/Store.html). Rails will create accessor methods for you.

### Type Casting the Value

Since `value` is stored as text, you may want to cast it to a different type. Override the `value` method and use ActiveRecord type casting.

~~~ ruby
# Cast to boolean (like the built-in Boolean ingredient)
def value
  ActiveRecord::Type::Boolean.new.cast(self[:value])
end

# Cast to datetime (like the built-in Datetime ingredient)
def value
  ActiveRecord::Type::DateTime.new.cast(self[:value])
end

# Cast to integer
def value
  ActiveRecord::Type::Integer.new.cast(self[:value])
end
~~~

### Allowing Settings

Use `allow_settings` to define which settings from `elements.yml` are available to your ingredient. Only safelisted settings are accessible via the `settings` hash.

~~~ ruby
class MyIngredient < Alchemy::Ingredient
  allow_settings %i[format display_mode]
end
~~~

~~~ yaml
# config/alchemy/elements.yml
- name: my_element
  ingredients:
    - role: custom
      type: MyIngredient
      settings:
        format: short
        display_mode: inline
~~~

### Customizing the Preview Text

The `preview_text` method controls what is shown in the element's title bar in the admin. By default it shows the first 30 characters of `value`. Override it to show something more meaningful.

~~~ ruby
class Person < Alchemy::Ingredient
  related_object_alias :person, class_name: "My::Person"

  def preview_text(maxlength = 30)
    return unless person

    person.name[0..maxlength - 1]
  end
end
~~~

## The View Component

The view component controls how the ingredient is rendered on your website. It extends `Alchemy::Ingredients::BaseView`.

~~~ ruby
# app/components/alchemy/ingredients/my_ingredient_view.rb
module Alchemy
  module Ingredients
    class MyIngredientView < BaseView
      def call
        content_tag(:div, ingredient.value)
      end
    end
  end
end
~~~

The `ingredient` accessor gives you access to the ingredient record, including its `value`, `settings`, and any `data` attributes or associations. Override `call` to return the HTML you want to render.

Override `render?` to control when the component renders. By default it renders when the ingredient has a value.

~~~ ruby
class PersonView < BaseView
  delegate :person, to: :ingredient

  def call
    content_tag(:span, person.name)
  end

  def render?
    !!person
  end
end
~~~

## The Editor Component

The editor component controls the form fields in the admin interface. It extends `Alchemy::Ingredients::BaseEditor`.

~~~ ruby
# app/components/alchemy/ingredients/my_ingredient_editor.rb
module Alchemy
  module Ingredients
    class MyIngredientEditor < BaseEditor
      # The default editor renders a text field for the `value` column.
      # Override `input_field` to customize the form input.
      #
      # def input_field
      #   text_field_tag(form_field_name, value)
      # end
    end
  end
end
~~~

The base editor provides helpers for building form fields:

- `form_field_name(column)` - generates the correct form field name for a column (defaults to `"value"`)
- `form_field_id(column)` - generates the correct form field ID for a column
- `value` - the current ingredient value
- `settings` - the ingredient's settings from the element definition

Override the `input_field` method to customize the editor UI. For example, to render a select box:

~~~ ruby
class MyIngredientEditor < BaseEditor
  def input_field
    select_tag(
      form_field_name,
      options_for_select(available_options, value),
      class: "full_width"
    )
  end

  private

  def available_options
    settings[:options] || []
  end
end
~~~

::: warning
Avoid loading large collections into the editor. If your `input_field` renders a `select_tag` with all records from a model (e.g. all products or all people), every element editor will trigger a database query for the full set. This causes N+1 queries and slow admin pages.

Instead, use a remote select that fetches results on demand via an API endpoint. Alchemy ships a `RemoteSelect` JavaScript base class (`alchemy_admin/components/remote_select`) that provides paginated, searchable selects using [Custom Elements](https://developer.mozilla.org/en-US/docs/Web/API/Web_components/Using_custom_elements). Your custom element extends `RemoteSelect`, implements `_searchQuery()` and `_parseResponse()`, and your editor component renders the custom element tag instead of a `select_tag`.

The [alchemy-solidus](extensions#alchemy-solidus) extension demonstrates this pattern. It defines `<alchemy-product-select>`, `<alchemy-variant-select>` and `<alchemy-taxon-select>` custom elements that query the Solidus API with pagination and search, avoiding loading thousands of records into memory.
:::

## Associating with Models

You can associate any ActiveRecord model with an ingredient using `related_object_alias`. This stores the foreign key in the `related_object_id` column and sets up a `belongs_to` association.

~~~ ruby
# app/models/alchemy/ingredients/person.rb
module Alchemy
  module Ingredients
    class Person < Alchemy::Ingredient
      related_object_alias :person, class_name: "My::Person"

      def preview_text(maxlength = 30)
        return unless person

        person.name[0..maxlength - 1]
      end
    end
  end
end
~~~

Alchemy handles the rest. You can access the associated model in your view component.

~~~ ruby
# app/components/alchemy/ingredients/person_view.rb
module Alchemy
  module Ingredients
    class PersonView < BaseView
      delegate :person, to: :ingredient

      def call
        content_tag(:span, person.name)
      end

      def render?
        !!person
      end
    end
  end
end
~~~

## Using Your Ingredient

Add your custom ingredient to any element definition in `elements.yml`.

~~~ yaml
- name: team_member
  ingredients:
    - role: person
      type: Person
~~~

See the [Elements guide](elements) for more on defining elements.
