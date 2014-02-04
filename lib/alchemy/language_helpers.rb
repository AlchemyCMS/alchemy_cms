module Alchemy
  module LanguageHelpers
    def self.included(controller)
      controller.send(:before_filter, :set_language)
    end

    private

    # Sets the language for rendering pages in pages controller.
    #
    def set_language(lang = nil)
      if lang
        @language = lang.is_a?(Language) ? lang : load_language_from(lang)
      else
        # find the best language and remember it for later
        @language = load_language_from_params ||
                    load_language_from_session ||
                    load_language_default
      end

      # store language in session
      store_language_in_session(@language)

      # switch locale to selected language
      ::I18n.locale = @language.code
    end

    def load_language_from_params
      if params[:lang].present?
        Language.find_by_code(params[:lang])
      end
    end

    def load_language_from_session
      if session[:language_id].present?
        Language.find_by_id(session[:language_id])
      end
    end

    def load_language_from(language_code_or_id)
      Language.find_by_id(language_code_or_id) || Language.find_by_code(language_code_or_id)
    end

    def load_language_default
      Language.get_default || raise(DefaultLanguageNotFoundError)
    end

    def store_language_in_session(language)
      if language && language.id
        session[:language_id]   = language.id
        session[:language_code] = language.code
      end
    end
  end
end
