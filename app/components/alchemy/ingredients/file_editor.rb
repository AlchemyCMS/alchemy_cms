# frozen_string_literal: true

module Alchemy
  module Ingredients
    class FileEditor < BaseEditor
      delegate :attachment, to: :ingredient
      delegate :link_to_dialog, to: :helpers

      def input_field
        content_tag("alchemy-file-editor", class: "file") do
          concat tag.div(
            render_icon(attachment&.icon_css_class),
            class: "file_icon"
          )
          concat tag.div(attachment&.name, class: "file_name")
          concat link_to(
            render_icon(:times), "#",
            class: [
              "remove_file_link",
              attachment ? nil : "hidden"
            ],
            data: {
              form_field_id: form_field_id(:attachment_id)
            }
          )
          concat(
            tag.div(class: "file_tools") do
              concat dialog_link
              concat link_to_dialog(
                render_icon(:edit),
                alchemy.edit_admin_ingredient_path(ingredient),
                {
                  title: Alchemy.t(:edit_file_properties),
                  size: "400x215"
                },
                title: Alchemy.t(:edit_file_properties)
              )
            end
          )
          concat hidden_field_tag(form_field_name(:attachment_id),
            attachment&.id,
            id: form_field_id(:attachment_id))
        end
      end

      private

      def dialog_link
        link_to_dialog(
          render_icon("file-add"),
          alchemy.admin_attachments_path(
            form_field_id: form_field_id(:attachment_id),
            only: Array(settings[:only]),
            except: Array(settings[:except])
          ),
          {
            title: Alchemy.t(:assign_file),
            size: "780x585",
            padding: false
          },
          class: "file_icon",
          title: Alchemy.t(:assign_file)
        )
      end
    end
  end
end
