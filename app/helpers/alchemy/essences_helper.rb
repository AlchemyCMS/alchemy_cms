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
    #   for_view: {}
    #   for_editor: {}
    #
    def render_essence(content, part = :view, options = {}, html_options = {})
      options = {for_view: {}, for_editor: {}}.update(options)
      if content.nil?
        return part == :view ? "" : warning('Content is nil', Alchemy.t(:content_not_found))
      elsif content.essence.nil?
        return part == :view ? "" : warning('Essence is nil', Alchemy.t(:content_essence_not_found))
      end
      render partial: "alchemy/essences/#{content.essence_partial_name}_#{part}", locals: {
        content: content,
        options: options["for_#{part}".to_sym],
        html_options: html_options
      }
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
      render_essence(content, :view, {for_view: options}, html_options)
    end
  end
end
