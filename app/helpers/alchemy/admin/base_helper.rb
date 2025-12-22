# frozen_string_literal: true

module Alchemy
  module Admin
    # This module contains helper methods for rendering dialogs and confirmation windows.
    #
    # The most important helpers for module developers are:
    #
    # * {#link_to_dialog}
    # * {#link_to_confirm_dialog}
    #
    module BaseHelper
      include Alchemy::BaseHelper
      include Alchemy::Admin::NavigationHelper

      # Returns a string showing the name of the currently logged in user.
      #
      # In order to represent your own +User+'s class instance,
      # you should add a +alchemy_display_name+ method to your +User+ class
      #
      def current_alchemy_user_name
        name = current_alchemy_user.try(:alchemy_display_name)
        if name.present?
          content_tag :span, class: "current-user-name" do
            "#{render_icon(:user, size: "1x")} #{name}".html_safe
          end
        end
      end

      # This helper renders the link to an dialog.
      #
      # We use this for our fancy modal dialogs in the Alchemy cockpit.
      #
      # == Example
      #
      #   <%= link_to_dialog('Edit', edit_product_path, {size: '200x300'}, {class: 'icon_button'}) %>
      #
      # @param [String] content
      #   The string inside the link tag
      # @param [String or Hash] url
      #   The url of the action displayed inside the dialog.
      # @param [Hash] options
      #   options for the dialog.
      # @param [Hash] html_options
      #   HTML options passed to the <tt>link_to</tt> helper
      #
      # @option options [String] :size
      #    String with format of "WidthxHeight". I.E. ("420x280")
      # @option options [String] :title
      #    Text for the dialog title bar.
      # @option options [Boolean] :modal (true)
      #    Show as modal window.
      #
      def link_to_dialog(content, url, options = {}, html_options = {})
        default_options = {modal: true}
        options = default_options.merge(options)
        if html_options[:title]
          tooltip = html_options.delete(:title)
        end
        anchor = link_to(content, url, html_options.merge(
          "data-dialog-options" => options.to_json,
          :is => "alchemy-dialog-link"
        ))
        if tooltip
          content_tag("sl-tooltip", anchor, content: tooltip)
        else
          anchor
        end
      end

      def alchemy_admin_js_translations(locale = ::I18n.locale)
        render partial: "alchemy/admin/translations/#{locale}", formats: [:js]
      rescue ActionView::MissingTemplate
        # Fallback to default translations
        render partial: "alchemy/admin/translations/en", formats: [:js]
      end

      # Used for site selector in Alchemy cockpit.
      def sites_for_select
        Alchemy::Site.all.map do |site|
          [site.name, site.id]
        end
      end

      # Returns a link that opens a modal confirmation to delete window.
      #
      # === Example:
      #
      #   <%= link_to_confirm_dialog('delete', 'Do you really want to delete this comment?', '/admin/comments/1') %>
      #
      # @param [String] link_string
      #   The content inside the <a> tag
      # @param [String] message
      #   The message that is displayed in the dialog
      # @param [String] url
      #   The url that gets opened after confirmation (Note: This is an Ajax request with a method of DELETE!)
      # @param [Hash] html_options
      #   HTML options get passed to the link
      #
      # @option html_options [String] :title (Alchemy.t(:please_confirm))
      #   The dialog title
      # @option html_options [String] :message (message)
      #   The message displayed in the dialog
      # @option html_options [String] :ok_label (Alchemy.t("Yes"))
      #   The label for the ok button
      # @option html_options [String] :cancel_label (Alchemy.t("No"))
      #   The label for the cancel button
      #
      def link_to_confirm_dialog(link_string = "", message = "", url = "", html_options = {})
        link_to(link_string, url,
          html_options.merge(
            data: {
              "turbo-method": :delete,
              "turbo-confirm": message
            }
          ))
      end

      # Returns a form and a button that opens a modal confirm dialog.
      #
      # After confirmation it proceeds to send the form's action.
      #
      # === Example:
      #
      #   <%= button_with_confirm('pay', '/admin/orders/1/pay', message: 'Do you really want to mark this order as payed?') %>
      #
      # @param [String] value
      #   The content inside the <tt><a></tt> tag
      # @param [String] url
      #   The url that gets opened after confirmation
      # @param [Hash] options
      #   Options for the Alchemy confirm dialog (see also +app/assets/javascripts/alchemy/alchemy.confirm_dialog.js.coffee+)
      # @param [Hash] html_options
      #   HTML options that get passed to the +button_tag+ helper.
      #
      # @note The method option in the <tt>html_options</tt> hash gets passed to the <tt>form_tag</tt> helper!
      #
      def button_with_confirm(value = "", url = "", options = {}, html_options = {})
        options = {
          message: Alchemy.t(:confirm_to_proceed),
          title: Alchemy.t(:please_confirm)
        }.merge(options)
        form_tag url, {method: html_options.delete(:method), class: "button-with-confirm"} do
          button_tag value, html_options.merge("data-turbo-confirm" => options[:message])
        end
      end

      # A delete button with confirmation window.
      #
      # @option title [String]
      #   The title for the confirm dialog
      # @option message [String]
      #   The message for the confirm dialog
      # @option icon [String]
      #   The icon class for the button
      #
      def delete_button(url, options = {}, html_options = {})
        options = {
          title: Alchemy.t("Delete"),
          message: Alchemy.t("Are you sure?"),
          icon: "delete-bin-2"
        }.merge(options)

        if html_options[:title]
          tooltip = html_options.delete(:title)
        end
        button = button_with_confirm(
          render_icon(options[:icon]),
          url, options, {
            method: "delete",
            class: "icon_button #{html_options.delete(:class)}".strip
          }.merge(html_options)
        )
        if tooltip
          content_tag("sl-tooltip", button, content: tooltip)
        else
          button
        end
      end

      # (internal) Renders translated Module Names for html title element.
      def render_alchemy_title
        title = if content_for?(:title)
          content_for(:title)
        else
          Alchemy.t(controller_name, scope: :modules)
        end
        "Alchemy CMS - #{title}"
      end

      # Renders a textfield ready to display a datepicker
      #
      # A Javascript observer converts this into a fancy Datepicker.
      # If you pass +'datetime'+ as +:type+ the datepicker will also have a Time select.
      # If you pass +'time'+ as +:type+ the datepicker will only have a Time select.
      #
      # This helper always renders "text" as input type because:
      # HTML5 supports input types like 'date' but Browsers are using the users OS settings
      # to validate the input format. Since Alchemy is localized in the backend the date formats
      # should be aligned with the users locale setting in the backend but not the OS settings.
      #
      # === Date Example
      #
      #   <%= alchemy_datepicker(@person, :birthday) %>
      #
      # === Datetime Example
      #
      #   <%= alchemy_datepicker(@page, :public_on, type: 'datetime') %>
      #
      # === Time Example
      #
      #   <%= alchemy_datepicker(@meeting, :starts_at, type: 'time') %>
      #
      # @param [ActiveModel::Base] object
      #   An instance of a model
      # @param [String or Symbol] method
      #   The attribute method to be called for the date value
      #
      # @option html_options [String] :data-datepicker-type (type)
      #   The value of the data attribute for the type
      # @option html_options [String] :class (type)
      #   CSS classes of the input field
      # @option html_options [String] :value (value of method on object)
      #   The value the input displays. If you pass a String its parsed with +Time.parse+
      #
      def alchemy_datepicker(object, method, html_options = {})
        type = html_options.delete(:type) || "date"
        date = html_options.delete(:value) || object.send(method.to_sym).presence
        date = Time.zone.parse(date) if date.is_a?(String)
        value = date&.iso8601

        input_field = text_field object.class.name.demodulize.underscore.to_sym,
          method.to_sym, {type: "text", class: type, value: value}.merge(html_options)

        content_tag("alchemy-datepicker", input_field, "input-type" => type)
      end

      # Render a hint icon with tooltip for given object.
      # The model class needs to include the hints module
      def render_hint_for(element, icon_options = {})
        return unless element.has_hint?

        content_tag "sl-tooltip", class: "like-hint-tooltip", placement: "bottom-start" do
          render_icon("question", icon_options) +
            content_tag(:span, element.hint.html_safe, slot: "content")
        end
      end

      # Appends the current controller and action to body as css class.
      def alchemy_body_class
        [
          controller_name,
          action_name,
          content_for(:main_menu_style),
          content_for(:alchemy_body_class)
        ].compact
      end

      # (internal) Returns options for the clipboard select tag
      def clipboard_select_tag_options(items)
        options = items.map do |item|
          name = if item.respond_to?(:display_name_with_preview_text)
            item.display_name_with_preview_text
          else
            item.name
          end
          [name, item.id]
        end
        options_for_select(options)
      end

      # Returns the regular expression used for external url validation in link dialog.
      def link_url_regexp
        Alchemy.config.format_matchers.link_url || /^(mailto:|\/|[a-z]+:\/\/)/
      end

      # Renders a hint with tooltip
      #
      # == Example
      #
      #   <%= hint_with_tooltip('Page layout is missing', icon: 'info') %>
      #
      # @param text [String] - The text displayed in the tooltip
      # @param icon: 'alert' [String] - Icon name
      #
      # @return [String]
      def hint_with_tooltip(text, icon: "alert", icon_class: nil)
        content_tag :"sl-tooltip", class: "like-hint-tooltip", content: text, placement: "bottom" do
          render_icon(icon, class: icon_class)
        end
      end

      # Renders a warning icon with a hint
      # that explains the user that the page layout is missing
      def page_layout_missing_warning
        hint_with_tooltip(
          Alchemy.t(:page_definition_missing)
        )
      end
    end
  end
end
