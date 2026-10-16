# How To: Create a Contact Form

Alchemy has a built-in contact form mailer that handles form submissions, validations, and email delivery. This guide walks you through setting it up.

::: info NOTE
Alchemy relies on Rails' [ActionMailer](https://guides.rubyonrails.org/action_mailer_basics.html) to send emails. You need to configure ActionMailer to use an SMTP service (Gmail, Sendgrid, Mailgun, Amazon SES, etc.) in your Rails environment configuration.
:::

## Mailer Configuration

Configure the mailer in your Alchemy initializer:

~~~ ruby
# config/initializers/alchemy.rb
Alchemy.config.tap do |config|
  config.mailer.mail_from = "noreply@example.com"
  config.mailer.mail_to = "contact@example.com"
  config.mailer.subject = "New contact form message"
  config.mailer.fields = %w[firstname lastname email message]
  config.mailer.validate_fields = %w[lastname email]
end
~~~

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `page_layout_name` | `String` | `"contact"` | Page layout name used for rendering the contact form |
| `forward_to_page` | `Boolean` | `false` | Redirect to the success page after sending |
| `mail_success_page` | `String` | `"thanks"` | URL name of the page shown after successful submission |
| `mail_from` | `String` | `"your.mail@your-domain.com"` | Sender email address |
| `mail_to` | `String` | `"your.mail@your-domain.com"` | Recipient email address |
| `subject` | `String` | `"A new contact form message"` | Email subject line |
| `fields` | `Array` | `[salutation, firstname, lastname, address, zip, city, phone, email, message]` | Field names for the contact form. These become attributes on the `Alchemy::Message` model |
| `validate_fields` | `Array` | `[lastname, email]` | Fields validated for presence. Fields matching `email` are also validated for email format |

::: tip
These defaults serve as fallbacks. You can make all of these configurable by editors through element ingredients (see below).
:::

## Creating the Contact Form Element

Define a contact form element in `config/alchemy/elements.yml`:

~~~ yaml
# config/alchemy/elements.yml
- name: contactform
  ingredients:
    - role: mail_from
      type: Text
      validate:
        - presence
        - format: email
    - role: mail_to
      type: Text
      validate:
        - presence
        - format: email
    - role: subject
      type: Text
      validate:
        - presence
    - role: success_page
      type: Page
      validate:
        - presence
~~~

::: info NOTE
The ingredients `mail_to`, `mail_from`, `subject` and `success_page` are recognized by the `Alchemy::MessagesController`. When present on the element, they override the mailer configuration defaults. This gives editors full control over these values.
:::

## Creating the Page Layout

Create a page layout for your contact page in `config/alchemy/page_layouts.yml`:

~~~ yaml
# config/alchemy/page_layouts.yml
- name: contact
  unique: true
  cache: false
  elements:
    - heading
    - contactform
  autogenerate:
    - contactform
~~~

::: warning
Disabling page caching with `cache: false` is important for contact form pages, otherwise the form's CSRF token may become stale.
:::

## The Contact Form View

Generate the element view partial:

~~~ bash
bin/rails g alchemy:elements --skip
~~~

Open `app/views/alchemy/elements/_contactform.html.erb` and replace the content with:

~~~ erb
<%= element_view_for(element) do |el| %>
  <%= simple_form_for(@message ||= Alchemy::Message.new) do |form| %>
    <%= form.input :firstname %>
    <%= form.input :lastname %>
    <%= form.input :email %>
    <%= form.input :message, as: :text %>
    <%= form.hidden_field :contact_form_id, value: element.id %>
    <%= form.button :submit %>
  <% end %>
<% end %>
~~~

::: warning
The `contact_form_id` hidden field is required. The `MessagesController` uses it to find the element and read its ingredient values for `mail_to`, `mail_from`, `subject`, and `success_page`.
:::

If you use different or additional fields (like `company` or `phone`), make sure they are listed in `Alchemy.config.mailer.fields`.

::: tip
Alchemy bundles [simple_form](https://github.com/heartcombo/simple_form), so you can use all Simple Form input types and options in your contact form view.
:::

## Translating Validation Messages

Validation messages are passed through `I18n.t`, so you can translate them in your locale files:

~~~ yaml
# config/locales/de.yml
de:
  activemodel:
    attributes:
      alchemy/message:
        firstname: Vorname
        lastname: Nachname
        email: E-Mail
        message: Nachricht
~~~

## Customizing the Mailer Template

Alchemy ships with plain-text email templates for English, German, and Spanish. To customize the email content, create your own template:

~~~ erb
<%# app/views/alchemy/messages_mailer/contact_form_mail.text.erb %>
New contact form message:

Name: <%= @message.firstname %> <%= @message.lastname %>
Email: <%= @message.email %>
Message: <%= @message.message %>
~~~

The template has access to `@message` with all configured field values as attributes.
