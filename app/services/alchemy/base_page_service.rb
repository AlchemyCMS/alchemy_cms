# frozen_string_literal: true

module Alchemy
  # Base class for page services that can be attached to page layouts
  # via the +service+ option in +page_layouts.yml+.
  #
  # Subclasses must implement {#call} to load data or perform logic
  # before the page is rendered.
  #
  # @abstract Subclass and override {#call} to implement a page service.
  class BasePageService
    attr_reader :page, :params, :preview_mode

    # @param page [Alchemy::Page] the page being rendered
    # @param params [ActionController::Parameters] the request parameters
    # @param preview_mode [Boolean] whether the page is rendered in admin preview
    def initialize(page, params: ActionController::Parameters.new, preview_mode: false)
      @page = page
      @params = params
      @preview_mode = preview_mode
    end

    # Entrypoint method of the page service.
    # It can initialize and load necessary data or raise an {Alchemy::PageNotFound} error.
    #
    # @abstract
    # @return [void]
    def call
      raise NotImplementedError
    end
  end
end
