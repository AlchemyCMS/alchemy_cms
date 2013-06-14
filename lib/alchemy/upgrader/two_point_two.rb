module Alchemy
  module Upgrader::TwoPointTwo

    class ContentsConverter
      include Alchemy::Shell

      def initialize(display_as, essence_type)
        @contents_found = 0
        @display_as = display_as
        @essence_type = essence_type
      end

      def convert!
        if essence_texts.any?
          essence_texts.each do |content|
            convert_content(content)
          end
        else
          log "No EssenceTexts displayed as #{@display_as} found.", :skip
        end
      end

    private

      def essence_texts
        Alchemy::Content.essence_texts.where(
          :name => content_names,
          :alchemy_elements => {:name => elements.collect { |e| e['name'] }}
        ).joins(:element)
      end

      def content_names
        @content_names ||= contents.collect { |c| c['name'] }
      end

      def contents
        @contents ||= elements.collect { |el|
          el['contents']
        }.flatten.select { |c|
          c['settings'] && c['settings']['display_as'] == @display_as
        }.flatten
      end

      def elements
        @elements ||= Alchemy::Element.descriptions.select { |e|
          e['contents'].present? && !e['contents'].detect { |c|
            c['settings'].present? && c['settings']['display_as'] == @display_as
          }.nil?
        }
      end

      def convert_content(content)
        if @new_content = new_content_from(content)
          update_content(content)
        else
          log "Could not create content: #{new_content.errors.full_messages.join(', ')}", :error
        end
      end

      def new_content_from(content)
        content = Alchemy::Content.create(
          element_id: content.element.id,
          name: content.name,
          essence_type: essence_class
        )
        content.essence = essence_class.constantize.create
        content
      end

      def essence_class
        "Alchemy::#{@essence_type.classify}"
      end

      def update_content(content)
        if update_essence_from(content)
          @contents_found += 1
          content.destroy
          log "Converted #{content.name}'s essence_type into #{@essence_type}"
        else
          log "Could not save essence: #{new_content.essence.errors.full_messages.join(', ')}", :error
        end
      end

      def update_essence_from(content)
        @new_content.essence.ingredient = content.ingredient
        @new_content.essence.save!
      end

      def display_result
        if @contents_found > 0
          todo "Please open your elements.yml file and change all type values from these contents:\n\n#{@content_names.join(', ')}\n\ninto #{@essence_type}."
        else
          log "No EssenceTexts with display_as #{@display_as} setting found.", :skip
        end
      end
    end

  private

    def convert_essence_texts_displayed_as_select_into_essence_selects
      desc "Converting all EssenceTexts displayed as select into EssenceSelects"
      converter = ContentsConverter.new('select', 'EssenceSelect')
      converter.convert!
    end

    def convert_essence_texts_displayed_as_checkbox_into_essence_booleans
      desc "Converting all EssenceTexts displayed as checkbox into EssenceBooleans"
      converter = ContentsConverter.new('checkbox', 'EssenceBoolean')
      converter.convert!
    end

  end

end
