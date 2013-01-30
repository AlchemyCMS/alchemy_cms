module Alchemy
  class EssenceRichtext < ActiveRecord::Base

    acts_as_essence(
      :preview_text_column => :stripped_body
    )

    attr_accessible :do_not_index, :body, :public, :stripped_body

    before_save :strip_content


    # Enable Ferret indexing.
    #
    # But only, if Ferret full text search is enabled (default).
    #
    # You can disable it in +config/alchemy/config.yml+
    #
    if Config.get(:ferret) == true
      require 'acts_as_ferret'
      acts_as_ferret(:fields => { :stripped_body => {:store => :yes} }, :remote => false)

      # Ensures that the current setting for do_not_index gets updated in the db.
      before_save { write_attribute(:do_not_index, description['do_not_index'] || false); return true }

      # Disables the ferret indexing, if do_not_index attribute is set to true
      #
      # You can disable indexing in the elements.yml file.
      #
      # === Example
      #
      #   name: secrets
      #   contents:
      #   - name: confidential
      #     type: EssenceRichtext
      #     do_not_index: true
      #
      def ferret_enabled?(is_bulk_index = false)
        !do_not_index?
      end
    end

  private

    def strip_content
      self.stripped_body = strip_tags(self.body)
    end

    # Stripping HTML Tags and only returns plain text.
    def strip_tags(html)
      return html if html.blank?
      if html.index("<")
        text = ""
        tokenizer = ::HTML::Tokenizer.new(html)
        while token = tokenizer.next
          node = ::HTML::Node.parse(nil, 0, 0, token, false)
          # result is only the content of any Text nodes
          text << node.to_s if node.class == ::HTML::Text
        end
        # strip any comments, and if they have a newline at the end (ie. line with
        # only a comment) strip that too
        text.gsub(/<!--(.*?)-->[\n]?/m, "")
      else
        html # already plain text
      end
    end

  end
end
