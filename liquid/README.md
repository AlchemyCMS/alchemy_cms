# alchemy-liquid

Opt-in [Liquid](https://shopify.github.io/liquid/) templates for AlchemyCMS element views and page layouts.

Liquid templates are regular view files (`.html.liquid`) that ActionView finds like any other template. So `render_element`, `render_elements`, `render_page_layout`, fragment caching and cache digests work as usual, and you can mix Liquid and ERB partials in one project.

Templates only see a curated, read-only set of attributes. They can't call arbitrary Ruby methods on your records.

## Installation

Add the gem to your application's Gemfile:

```bash
bundle add alchemy-liquid
```

That's it: the gem registers the `.liquid` template handler.

### Generating views

The Alchemy view generators accept `liquid` as their template engine:

```bash
bin/rails g alchemy:elements --template-engine liquid
bin/rails g alchemy:page_layouts --template-engine liquid
```

If a partial already exists with another template engine, the generators keep that engine, just like they do for erb, haml and slim.

## A sample element view

Given this element definition

```yaml
# config/alchemy/elements.yml
- name: article
  ingredients:
    - role: headline
      type: Headline
    - role: image
      type: Picture
    - role: text
      type: Richtext
  nestable_elements: [quote]
```

the element view `app/views/alchemy/elements/_article.html.liquid` could look like this:

```liquid
{% cache element %}
  {% element_view element, tag: "article", class: "article" %}
    {% ingredient "headline" %}

    {% if element.ingredients.image.present %}
      <figure>
        <img src="{{ element.ingredients.image | picture_url: size: "800x600", crop: true }}"
          alt="{{ element.ingredients.image.alt_tag }}">
        <figcaption>{{ element.ingredients.image.caption }}</figcaption>
      </figure>
    {% endif %}

    {% ingredient "text" %}

    {% elements element.nested_elements %}

    <a href="{{ element.page | url }}">{{ "read_more" | t }}</a>
  {% endelement_view %}
{% endcache %}
```

And a page layout `app/views/alchemy/page_layouts/_standard.html.liquid`:

```liquid
<main>
  {% elements except: "footer" %}
</main>
<footer>
  {% menu "footer_navigation" %}
  {% elements only: "footer" %}
</footer>
```

## Variables

The locals of the partial are passed to the template. Alchemy records are wrapped into drops:

- element partials get `element`, `counter` and `options`
- page layouts get `page`

## Escaping

Liquid does not escape output. To be safe by default, every text value read from a drop is already HTML escaped (for example `{{ element.ingredients.text.value }}` or `{{ page.name }}`). The `escape` filter doesn't escape those values twice.

To render markup (rich text, HTML ingredients, pictures, links) use the `ingredient` tag. It renders the ingredient's view component, which handles sanitizing.

## Drops

### `element` (`ElementDrop`)

| Attribute         | Description                                              |
| ----------------- | -------------------------------------------------------- |
| `id`              | The element's id                                         |
| `name`            | The element's name                                       |
| `tag_list`        | The element's tags                                       |
| `ingredients`     | The ingredients by role (`element.ingredients.headline`) |
| `nested_elements` | The visible nested elements                              |
| `page`            | The page of the element                                  |

You can also loop over the ingredients with `{% for ingredient in element.ingredients %}`.

### `ingredient` (`IngredientDrop`)

| Attribute | Description                                                                                                                                                   |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`      | The ingredient's id                                                                                                                                           |
| `role`    | The ingredient's role                                                                                                                                         |
| `type`    | The ingredient type, e.g. `Text` or `Picture`                                                                                                                 |
| `value`   | The value. Text is escaped, related pages and nodes are drops. Pictures and attachments are not exposed. Use the `ingredient` tag or the filters for them. |
| `present` | `true` if the ingredient has a value. `{% if ingredient == blank %}` works too.                                                                               |

Every attribute an ingredient stores in its `data` column can be read as well, for example `alt_tag`, `caption`, `title`, `link`, `link_title`, `link_target` or `level`, depending on the ingredient type.

### `page` (`PageDrop`)

`id`, `name`, `title`, `urlname`, `url`, `page_layout`, `language_code`, `meta_description`, `meta_keywords`, `published_at`, `public_on`, `parent`

### `node` (`NodeDrop`)

`id`, `name`, `title`, `url`, `nofollow`, `external`, `menu_type`, `page`, `children`

## Tags

| Tag            | Example                                                                         | Description                                                                                                                                                       |
| -------------- | ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ingredient`   | `{% ingredient "image", size: "300x200" %}`                                     | Renders an ingredient with its view component (`Alchemy::Ingredients::*View`). Takes a role (looked up on `element`, or on `element: other`) or an ingredient drop. Other arguments are passed to the component. |
| `elements`     | `{% elements only: "article,text" %}`                                           | Renders the page's elements with `render_elements`. Supports `only:` and `except:` as an array or a comma separated string.                                       |
|                | `{% elements element.nested_elements %}`                                        | Renders the given elements with `render_element`.                                                                                                                 |
| `menu`         | `{% menu "main_menu" %}`                                                        | Renders a menu with `render_menu`. Other arguments are passed as options to the menu partials.                                                                    |
| `element_view` | `{% element_view element, tag: "section" %}...{% endelement_view %}`            | Wraps the content with `element_view_for`, which adds the attributes the page preview needs. Supports `tag:`, `class:` and `id:`. Defaults to the `element` variable. |
| `cache`        | `{% cache element %}...{% endcache %}`                                          | Fragment caching with the Rails `cache` helper. The cache key includes the template digest. Supports `expires_in:`.                                               |

## Filters

| Filter        | Example                                                     | Description                                                                                       |
| ------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `t`           | `{{ "greeting" \| t: name: page.name }}`                    | Translates with the Rails `t` helper. Keys starting with a dot are relative to the template.      |
| `url`         | `{{ page \| url }}`                                         | The url of a page, a node, or a Page, Node or Link ingredient (or the `link` of a linkable one). |
| `picture_url` | `{{ element.ingredients.image \| picture_url: size: "300x200" }}` | The url of a picture ingredient. Accepts the options of `Alchemy::Ingredients::Picture#picture_url`. |
| `format_date` | `{{ page.published_at \| format_date: "short" }}`           | Localizes a date or time with the Rails `l` helper.                                               |

All [standard Liquid filters](https://shopify.github.io/liquid/filters/) are available too.

## Custom tags and filters

Alchemy uses its own Liquid environment, so its tags and filters don't leak into other Liquid templates of your app. Register your own tags and filters in an initializer:

```ruby
# config/initializers/alchemy_liquid.rb
Alchemy::Liquid.configure_environment do |env|
  env.register_filter(MyFilters)
  env.register_tag("my_tag", MyTag)
end
```

Tags and filters can reach the view context with `context.registers[:view]`, and the record of a drop with `Alchemy::Liquid.unwrap(drop)`.

## Errors

Templates are parsed in strict error mode and unknown filters raise an error, so mistakes show up during development instead of rendering empty output.

## License

BSD-3-Clause, see [LICENSE](LICENSE).
