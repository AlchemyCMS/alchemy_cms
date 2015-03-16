Best Practice: How to create Form
---------------------------------

This guide covers the configuration setup and create process of a
regular contact form:

-   Setup Alchemy mailer
-   …..

endprologue.

### Mailer Settings

This is the default mailer configuration.

<yaml>\
mailer:\
 page\_layout\_name: contact\
 forward\_to\_page: false\
 mail\_success\_page: thanks\
 mail\_from: your.mail@your-domain.com\
 mail\_to: your.mail@your-domain.com\
 fields: [salutation, firstname, lastname, address, zip, city, phone,
email, message]\
 validate\_fields: [lastname, email]\
</yaml>

-   <code>page\_layout\_name</code><code>String</code><br>\
     (Optional) A Alchemy::PageLayout name. Used for rendering the
    contact form.
-   <code>forward\_to\_page</code><code>Boolean</code><br>\
     (Optional) If set to true the mailer redirects to the page defined
    with mail\_success\_page option.
-   <code>mail\_success\_page</code><code>String</code><br>\
     (Optional) A page urlname that should be displayed after
    succesfully sending the mail.
-   <code>mail\_from</code><code>String</code><br>\
     (Optional) The email address the mail is send from.
-   <code>mail\_to</code><code>String</code><br>\
     (Optional) The email address the mail is send to.
-   <code>fields</code><code>Array</code><br>\
     Field names of your contact form. These fields become attributes on
    the Message Model
-   <code>validate\_fields</code><code>Array</code><br>\
     Field names of your contact form that should be validated for
    presence.

INFO: All optional setting should be managable through the content
management user. So creating an element that set these values is
<strong>highly recommended</strong>.

### Creating a contact form element

Describe a new Element with this options inside your
<code>elements.yml</code> file:

<yaml>\
- name: contactform\
 contents:\
 - name: mail\_from\
 type: EssenceText\
 validate:\
 - presence\
 - format: email\
 - name: mail\_to\
 type: EssenceText\
 validate:\
 - presence\
 - format: email\
 - name: subject\
 type: EssenceText\
 validate:\
 - presence\
 - name: success\_page\
 type: EssenceSelect\
 validate:\
 - presence\
</yaml>

INFO: The fields <code>mail\_to</code>, <code>mail\_from</code>,
<code>subject</code> and <code>success\_page</code> are recommended. The
<code>Alchemy::MessagesController</code> uses them to send your mails.
That way your customer has full control over these values inside his
contact form element.

NOTE: The validations are optional, but <strong>highly
recommended</strong>.

Create a page layout for your contact page in the
<code>page\_layouts.yml</code> file:

<yaml>\
- name: contact\
 unique: true\
 cache: false\
 elements: [pageheading, heading, contactform]\
 autogenerate: [contactform]\
</yaml>

INFO: Disabling the page caching is <strong>highly recommended</strong>!

#### Example contact form

Use the <code>rails g alchemy:elements —skip</code> generator to create
the view files.

##### The contact form view

Open
<code>app/views/alchemy/elements/\_contactform\_view.html.erb</code> in
your text editor.

We are using the great <code>simple\_form</code> gem in this example.\
If this gem is not already installed, you have to add\
<ruby>\
 gem ‘simple\_form’\
</ruby>\
to your Gemfile and afterwards use <shell>bundle </shell> command to
install <code>simple\_form</code>.

<erb>\
\<= simple\_form\_for(@message ||= Alchemy::Message.new) do |form|\>\
 \<= form.input :firstname\>\
 \<= form.input :lastname\>\
 \<= form.input :email\>\
 \<= form.input :message, :as =\> :text\>\
 \<= form.hidden\_field :contact\_form\_id, :value =\> element.id\>\
 \<= form.button :submit\>\
\<% end %\>\
</erb>

NOTE: See the hidden field? This is important, or the messages mailer
can’t do all the magic for you.

If you use different or additional input symbols like ‘company’ , ‘age’
etc. make sure to adapt the fields in the mailer configuration
(<code>config/alchemy/config.yml</code>).

INFO: Please have a look at the [simple form
documentation](https://github.com/plataformatec/simple_form#readme) for
further infos about the various config options.

##### The contact form editor

The
<code>app/views/alchemy/elements/\_contactform\_editor.html.erb</code>
file should have this layout:

<erb>\
\<= element\_editor\_for(element) do |el| -\>\
 \<= el.edit :mail\_from\>\
 \<= el.edit :mail\_to\>\
 \<= el.edit :subject\>\
 \<= el.edit :success\_page, :select\_values =\> pages\_for\_select(nil,
element.ingredient(:success\_page), “Choose page”, :urlname)\>\
\<- end -\>\
</erb>

INFO: The <code>page\_selector</code> helper is pretty handy for setting
the success page.\
Note that the <code>:page\_attribute</code> option is important. Leaving
it the default <code>:id</code> value breaks the message controller.

### Translating validation messages

All validation messages are passed through <code>::I18n.t</code> so you
can translate it in your language yml file.

#### Example Translation

<yaml>\
de:\
 activemodel:\
 attributes:\
 alchemy/message:\
 firstname: Vorname\
 lastname: Nachname\
</yaml>

INFO: If you like to use same vocabulary in different context:

e.g in the <code>app/views/alchemy/elements/\_contactform\_view.html.erb
</code>

<erb>\
 \<= form.input …\>\
 \<= form.input :firstname , label: t(:sender, scope:
’my\_forms.contactform’)\>\
 \<= form.input …\>\
</erb>

Your language yml should look like this:
(<code>config/locales/de.yml</code>)

<yaml>\
my\_forms:\
 contactform:\
 sender: Sender\
</yaml>

Now you can reuse the label by using the <code> t</code> function while
defining label.
