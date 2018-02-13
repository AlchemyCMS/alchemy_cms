# frozen_string_literal: true

module Alchemy
  module Admin
    # This module contains helper methods for rendering dialogs, toolbar buttons and confirmation windows.
    #
    # The most important helpers for module developers are:
    #
    # * {#toolbar}
    # * {#toolbar_button}
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
          content_tag :span, "#{Alchemy.t('Logged in as')} #{name}", class: 'current-user-name'
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
        link_to content, url,
          html_options.merge('data-alchemy-dialog' => options.to_json)
      end

      # Used for translations selector in Alchemy cockpit user settings.
      def translations_for_select
        Alchemy::I18n.available_locales.sort.map do |locale|
          [Alchemy.t(locale, scope: :translations), locale]
        end
      end

      # Used for site selector in Alchemy cockpit.
      def sites_for_select
        Alchemy::Site.all.map do |site|
          [site.name, site.id]
        end
      end

      # Returns a javascript driven live filter for lists.
      #
      # The items must have a html +name+ attribute that holds the filterable value.
      #
      # == Example
      #
      # Given a list of items:
      #
      #   <%= js_filter_field('#products .product') %>
      #
      #   <ul id="products">
      #     <li class="product" name="kat litter">Kat Litter</li>
      #     <li class="product" name="milk">Milk</li>
      #   </ul>
      #
      # @param [String] items
      #   A jquery compatible selector string that represents the items to filter
      # @param [Hash] options
      #   HTML options passed to the input field
      #
      # @option options [String] :class ('js_filter_field')
      #   The css class of the <input> tag
      # @option options [String or Hash] :data ({'alchemy-list-filter' => items})
      #   A HTML data attribute that holds the jQuery selector that represents the list to be filtered
      #
      def js_filter_field(items, options = {})
        options = {
          class: 'js_filter_field',
          data: {'alchemy-list-filter' => items}
        }.merge(options)
        content_tag(:div, class: 'js_filter_field_box') do
          concat text_field_tag(nil, nil, options)
          concat render_icon(:search)
          concat link_to(render_icon(:times, size: 'xs'), '', class: 'js_filter_field_clear', title: Alchemy.t(:click_to_show_all))
          concat content_tag(:label, Alchemy.t(:search), for: options[:id])
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
            'data-alchemy-confirm-delete' => {
              title: Alchemy.t(:please_confirm),
              message: message,
              ok_label: Alchemy.t("Yes"),
              cancel_label: Alchemy.t("No")
            }.to_json
          )
        )
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
          ok_label: Alchemy.t("Yes"),
          title: Alchemy.t(:please_confirm),
          cancel_label: Alchemy.t("No")
        }.merge(options)
        form_tag url, {method: html_options.delete(:method), class: 'button-with-confirm'} do
          button_tag value, html_options.merge('data-alchemy-confirm' => options.to_json)
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
          title: Alchemy.t('Delete'),
          message: Alchemy.t('Are you sure?'),
          icon: :minus
        }.merge(options)
        button_with_confirm(
          render_icon(options[:icon]),
          url, {
            message: options[:message]
          }, {
            method: 'delete',
            title: options[:title],
            class: "icon_button #{html_options.delete(:class)}".strip
          }.merge(html_options)
        )
      end

      # (internal) Renders translated Module Names for html title element.
      def render_alchemy_title
        if content_for?(:title)
          title = content_for(:title)
        else
          title = Alchemy.t(controller_name, scope: :modules)
        end
        "Alchemy CMS - #{title}"
      end

      # Renders a toolbar button for the Alchemy toolbar
      #
      # == Example
      #
      #   <%= toolbar_button(
      #     icon: :plus,
      #     label: 'Create',
      #     url: new_resource_path,
      #     title: 'Create Resource',
      #     hotkey: 'alt+n',
      #     dialog_options: {
      #       title: 'Create Resource',
      #       size: "430x400"
      #     },
      #     if_permitted_to: [:create, resource_model]
      #   ) %>
      #
      # @option options [String] :icon
      #   Icon class. See +app/assets/stylesheets/alchemy/icons.css.sccs+ for available icons, or make your own.
      # @option options [String] :label
      #   Text for button label.
      # @option options [String] :url
      #   Url for link.
      # @option options [String] :title
      #   Text for title tag.
      # @option options [String] :hotkey
      #   Keyboard shortcut for this button. I.E +alt-n+
      # @option options [Boolean] :dialog (true)
      #   Open the link in a modal dialog.
      # @option options [Hash] :dialog_options
      #   Overlay options. See link_to_dialog helper.
      # @option options [Array] :if_permitted_to ([:action, :controller])
      #   Check permission for button. Exactly how you defined the permission in your +authorization_rules.rb+. Defaults to controller and action from button url.
      # @option options [Boolean] :skip_permission_check (false)
      #   Skip the permission check. NOT RECOMMENDED!
      # @option options [Boolean] :loading_indicator (true)
      #   Shows the please wait dialog while loading. Only for buttons not opening an dialog.
      #
      def toolbar_button(options = {})
        options = {
          dialog: true,
          skip_permission_check: false,
          active: false,
          link_options: {},
          dialog_options: {},
          loading_indicator: false
        }.merge(options.symbolize_keys)
        button = render(
          'alchemy/admin/partials/toolbar_button',
          options: options
        )
        if options[:skip_permission_check] || can?(*permission_from_options(options))
          button
        else
          ""
        end
      end

      # Renders the toolbar shown on top of the records.
      #
      # == Example
      #
      #   <% label_title = Alchemy.t("Create #{resource_name}", default: Alchemy.t('Create')) %>
      #   <% toolbar(
      #     buttons: [
      #       {
      #         icon: :plus,
      #         label: label_title,
      #         url: new_resource_path,
      #         title: label_title,
      #         hotkey: 'alt+n',
      #         dialog_options: {
      #           title: label_title,
      #           size: "430x400"
      #         },
      #         if_permitted_to: [:create, resource_model]
      #       }
      #     ]
      #   ) %>
      #
      # @option options [Array] :buttons ([])
      #   Pass an Array with button options. They will be passed to {#toolbar_button} helper.
      # @option options [Boolean] :search (true)
      #   Show searchfield.
      #
      def toolbar(options = {})
        defaults = {
          buttons: [],
          search: true
        }
        options = defaults.merge(options)
        content_for(:toolbar) do
          content = <<-CONTENT.strip_heredoc
            #{options[:buttons].map { |button_options| toolbar_button(button_options) }.join}
            #{render('alchemy/admin/partials/search_form', url: options[:search_url]) if options[:search]}
          CONTENT
          content.html_safe
        end
      end

      # (internal) Used by upload form
      def new_asset_path_with_session_information(asset_type)
        session_key = Rails.application.config.session_options[:key]
        if asset_type == "picture"
          alchemy.admin_pictures_path(session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token, :format => :js)
        elsif asset_type == "attachment"
          alchemy.admin_attachments_path(session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token, :format => :js)
        end
      end

      # Renders a textfield ready to display a datepicker
      #
      # A Javascript observer converts this into a fancy Datepicker.
      # If you pass +'datetime'+ as +:type+ the datepicker will also have a Time select.
      # If you pass +'time'+ as +:type+ the datepicker will only have a Time select.
      #
      # The date value gets localized via +I18n.l+. The format on Time and Date is +datepicker+, +timepicker+
      # or +datetimepicker+, if you pass another +type+.
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
        type = html_options.delete(:type) || 'date'
        date = html_options.delete(:value) || object.send(method.to_sym).presence
        date = Time.zone.parse(date) if date.is_a?(String)
        value = date ? l(date, format: "alchemy.#{type}picker".to_sym) : nil

        text_field object.class.name.demodulize.underscore.to_sym,
          method.to_sym, {type: "text", class: type, "data-datepicker-type" => type, value: value}.merge(html_options)
      end

      # Render a hint icon with tooltip for given object.
      # The model class needs to include the hints module
      def render_hint_for(element)
        return unless element.has_hint?
        content_tag :span, class: 'hint-with-icon' do
          render_icon('question-circle') +
            content_tag(:span, element.hint.html_safe, class: 'hint-bubble')
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
        if @page.persisted? && @page.can_have_cells?
          grouped_options_for_select(grouped_elements_for_select(items, :id))
        else
          options = items.map do |item|
            [item.respond_to?(:display_name_with_preview_text) ? item.display_name_with_preview_text : item.name, item.id]
          end
          options_for_select(options)
        end
      end

      # Returns the regular expression used for external url validation in link dialog.
      def link_url_regexp
        Alchemy::Config.get(:format_matchers)['link_url'] || /^(mailto:|\/|[a-z]+:\/\/)/
      end

      # Renders a hint with tooltip
      #
      # == Example
      #
      #   <%= hint_with_tooltip('Page layout is missing', icon: 'info') %>
      #
      # @param text [String] - The text displayed in the tooltip
      # @param icon: 'exclamation-triangle' [String] - Icon name
      #
      # @return [String]
      def hint_with_tooltip(text, icon: 'exclamation-triangle')
        content_tag :span, class: 'hint-with-icon' do
          render_icon(icon) + content_tag(:span, text, class: 'hint-bubble')
        end
      end

      # Renders a warning icon with a hint
      # that explains the user that the page layout is missing
      def page_layout_missing_warning
        hint_with_tooltip(
          Alchemy.t(:page_definition_missing)
        )
      end

      private

      def permission_from_options(options)
        if options[:if_permitted_to].blank?
          options[:if_permitted_to] = permission_array_from_url(options)
        else
          options[:if_permitted_to]
        end
      end

      def permission_array_from_url(options)
        action_controller = options[:url].gsub(/\A\//, '').split('/')
        [
          action_controller.last.to_sym,
          action_controller[0..action_controller.length - 2].join('_').to_sym
        ]
      end
    end
  end
end
