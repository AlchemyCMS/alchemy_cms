module Alchemy

  # This helper contains methods to render the +essence+ from an +Element+ +Content+.
  #
  # Essences have two kinds of partials. An +editor+ and a +view+ partial.
  #
  # They both resist in +'app/views/alchemy/essences'+
  #
  # The partials are suffixed with the type of part.
  #
  # == Example:
  #
  # For an EssenceText
  #
  # The view partial is:
  #
  # +_essence_text_view.html.erb+
  #
  # The editor partial is:
  #
  # +_essence_text_editor.html.erb+
  #
  # == Usage:
  #
  # For front end web development you should mostly use the +render_essence_view_by_name+ helper.
  #
  # And the +render_essence_editor_by_name+ helper for Alchemy backend views.
  #
  module EssencesHelper

    # Renders the +Essence+ view partial from +Element+ by name.
    #
    # Pass the name of the +Content+ from +Element+ as second argument.
    #
    # == Example:
    #
    # This renders the +Content+ named "intro" from element.
    #
    #   <%= render_essence_view_by_name(element, "intro") %>
    #
    def render_essence_view_by_name(element, name, options = {}, html_options = {})
      if element.blank?
        warning('Element is nil')
        return ""
      end
      content = element.content_by_name(name)
      render_essence_view(content, options, html_options)
    end

    # Renders the +Essence+ view partial from given +Element+ and +Essence+ type.
    #
    # Pass the type of +Essence+ you want to render from +element+ as second argument.
    #
    # By default the first essence gets rendered. You may pass a different position value as third argument.
    #
    # == Example:
    #
    # This renders the first +Content+ with type of +EssencePicture+ from element.
    #
    #   <%= render_essence_view_by_type(element, "EssencePicture", 1, {:image_size => "120x80", :crop => true}) %>
    #
    def render_essence_view_by_type(element, type, position = 1, options = {}, html_options = {})
      if element.blank?
        warning('Element is nil')
        return ""
      end
      if position == 1
        content = element.content_by_type(type)
      else
        content = element.contents.find_by_essence_type_and_position(Alchemy::Content.normalize_essence_type(type), position)
      end
      render_essence_view(content, options, html_options)
    end

    # Renders the +Essence+ view partial from +Element+ by position.
    #
    # Pass the position of the +Content+ inside the Element as second argument.
    #
    # == Example:
    #
    # This renders the second +Content+ from element.
    #
    #   <%= render_essence_view_by_type(element, 2) %>
    #
    def render_essence_view_by_position(element, position, options = {}, html_options = {})
      ActiveSupport::Deprecation.warn 'Alchemy CMS: render_essence_view_by_position is not supported anymore and will be removed.'
      if element.blank?
        warning('Element is nil')
        return ""
      end
      content = element.contents.find_by_position(position)
      render_essence_view(content, options, html_options)
    end

    # Renders the +Esssence+ partial for given +Content+.
    #
    # The helper renders the view partial as default.
    #
    # Pass +:editor+ as second argument to render the editor partial
    #
    # == Options:
    #
    # You can pass a options Hash to each type of essence partial as third argument.
    #
    # This Hash is available as +options+ local variable.
    #
    #   :for_view => {}
    #   :for_editor => {}
    #
    def render_essence(content, part = :view, options = {}, html_options = {})
      options = {:for_view => {}, :for_editor => {}}.update(options)
      if content.nil?
        return part == :view ? "" : warning('Content is nil', _t("content_not_found"))
      elsif content.essence.nil?
        return part == :view ? "" : warning('Essence is nil', _t("content_essence_not_found"))
      end
      render(
        :partial => "alchemy/essences/#{content.essence_partial_name}_#{part.to_s}",
        :locals => {
          :content => content,
          :options => options["for_#{part}".to_sym],
          :html_options => html_options
        }
      )
    end

    # Renders the +Esssence+ view partial for given +Content+.
    #
    # == Options:
    #
    #   :image_size => "111x93"                        # Used by EssencePicture to render the image via RMagick to that size. [Default nil]
    #   :date_format => "Am %d. %m. %Y, um %H:%Mh"     # Especially for EssenceDate. See Rubys Date.strftime for date formatting options. [Default nil]
    #   :show_caption => false                         # Pass Boolean to show/hide the caption of an EssencePicture. [Default true]
    #   :disable_link => true                          # You can surpress the link of an EssencePicture. Default false
    #
    def render_essence_view(content, options = {}, html_options = {})
      render_essence(content, :view, {:for_view => options}, html_options)
    end

    # Renders a essence picture
    #
    def render_essence_picture_view(content, options, html_options)
      options = {:show_caption => true, :disable_link => false}.update(options)
      return if content.essence.picture.blank?
      if content.essence.caption.present? && options[:show_caption]
        caption = content_tag(:figcaption, content.essence.caption, :id => "#{dom_id(content.essence.picture)}_caption", :class => "image_caption")
      end
      img_tag = image_tag(
        show_alchemy_picture_url(content.essence.picture,
          options.merge(
            :size => options.delete(:image_size),
            :crop_from => options[:crop] && !content.essence.crop_from.blank? ? content.essence.crop_from : nil,
            :crop_size => options[:crop] && !content.essence.crop_size.blank? ? content.essence.crop_size : nil
          ).delete_if { |k, v| v.blank? || k.to_sym == :show_caption || k.to_sym == :disable_link }
        ),
        {
          :alt => (content.essence.alt_tag.blank? ? nil : content.essence.alt_tag),
          :title => (content.essence.title.blank? ? nil : content.essence.title),
          :class => (caption || content.essence.css_class.blank? ? nil : content.essence.css_class)
        }.merge(caption ? {} : html_options)
      )
      output = caption ? img_tag + caption : img_tag
      if content.essence.link.present? && !options[:disable_link]
        output = link_to(url_for(content.essence.link), {
          :title => content.essence.link_title.blank? ? nil : content.essence.link_title,
          :target => (content.essence.link_target == "blank" ? "_blank" : nil),
          'data-link-target' => content.essence.link_target.blank? ? nil : content.essence.link_target
        }) do
          output
        end
      end
      if caption
        content_tag(:figure, output, {class: content.essence.css_class.blank? ? nil : content.essence.css_class}.merge(html_options))
      else
        output
      end
    end

  end
end
