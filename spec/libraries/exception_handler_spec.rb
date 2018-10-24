# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe ExceptionHandler do
    it "allows setting a custom exception handler class" do
      expect(Alchemy.exception_handler.class).to eq(Alchemy::ExceptionHandler)

      Alchemy.exception_handler = 'foobar'

      expect(Alchemy.exception_handler).to eq('foobar')

      Alchemy.exception_handler = Alchemy::ExceptionHandler.new
    end

    it "responds to .call" do
      expect { Alchemy.exception_handler.call(StandardError.new, ApplicationController.new) }.to raise_error(StandardError)
    end
  end
end
