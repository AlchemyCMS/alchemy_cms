# How To: Create a contact form

This guide covers the configuration setup and create process of a
regular contact form:

-   Setup Alchemy mailer
-   Customize the views

## Additional Rails and application setup

Alchemy relies on Rails' [ActionMailer](https://guides.rubyonrails.org/action_mailer_basics.html) to send emails.
You will need to configure ActionMailer to use an SMTP service like Gmail, Sendgrid, Mailgun, Mandrill, Amazon SES, etc.

## Mailer Settings

This is the default mailer configuration in `config/alchemy/config.yml`:

~~~ yaml
mailer:
  page_layout_name: contact
  forward_to_page: false
  mail_success_page: thanks
  mail_from: your.mail@your-domain.com
  mail_to: your.mail@your-domain.com
  fields: [salutation, firstname, lastname, address, zip, city, phone, email, message]
  validate_fields: [lastname, email]
~~~

- **page_layout_name** `String` (Optional)

  A `Alchemy::PageLayout` name. Used for rendering the contact form.

- **forward_to_page** `Boolean` (Optional)

  If set to true the mailer redirects to the page defined with mail_success_page option.

- **mail_success_page** `String` (Optional)

  A page urlname that should be displayed after successfully sending the mail.

- **mail_from** `String` (Optional)

  The email address the mail is send from.

- **mail_to** `String` (Optional)

  The email address the mail is send to.

- **fields** `Array`

  Field names of your contact form. These fields become attributes on the `Alchemy::Message` Model

- **validate_fields** `Array`

  Field names of your contact form that should be validated for presence.

::: tip NOTE
All optional setting should be manageable through the content management user. So creating an element that set these values is **highly recommended**.
:::

## Creating a contact form element

Describe a new Element with this options inside your `elements.yml` file:

~~~ yaml
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

::: tip NOTE
The fields `mail_to`, `mail_from`, `subject` and `success_page` are recommended. The `Alchemy::MessagesController` uses them to send your mails. That way your customer has full control over these values inside his contact form element.
:::

::: warning INFO
The validations are optional, but **highly recommended**.
:::

Create a page layout for your contact page in the `page_layouts.yml` file:

~~~ yaml
- name: contact
  unique: true
  cache: false
  elements:
    - pageheading
    - heading
    - contactform
  autogenerate:
    - contactform
~~~

::: warning INFO
Disabling the page caching is **very important**!
:::

## Example contact form

Use the `rails g alchemy:elements --skip` generator to create the view files.

### The contact form view

We are using the great `simple_form` gem in this example.

If this gem is not already installed, you have to add

~~~ bash
bundle add simple_form
~~~

Then open `app/views/alchemy/elements/_contactform.html.erb` in your text editor
and replace the content with:

~~~ erb
<%= simple_form_for(@message ||= Alchemy::Message.new) do |form| %>
  <%= form.input :firstname %>
  <%= form.input :lastname %>
  <%= form.input :email %>
  <%= form.input :message, as: 'text' %>
  <%= form.hidden_field :contact_form_id, value: element.id %>
  <%= form.button :submit %>
<% end %>
~~~

::: warning INFO
See the `hidden_field`? This is important, or the messages mailer can't do all the magic for you.
:::

If you use different or additional input symbols like 'company' , 'age' etc. make sure to adapt the fields in the mailer configuration (`config/alchemy/config.yml`).

::: tip
Please have a look at the [simple form documentation](https://github.com/plataformatec/simple_form#readme) for further infos about the various config options.
:::

## Translating validation messages

All validation messages are passed through `::I18n.t` so you can translate it in your language yml file.

### Example Translation

~~~ yaml
de:
  activemodel:
    attributes:
      alchemy/message:
        firstname: Vorname
        lastname: Nachname
~~~

If you would like to use same vocabulary in different context: e.g in the `app/views/alchemy/elements/_contactform_view.html.erb`

~~~ erb
<%= form.input ... %>
<%= form.input :firstname , label: t(:sender, scope: 'my_forms.contactform') %>
<%= form.input ... %>
~~~

Your language yml should look like this: (`config/locales/de.yml`)

~~~ yaml
de:
  my_forms:
    contactform:
      sender: Sender
~~~

Now you can reuse the label by using the `t` function while defining label.
