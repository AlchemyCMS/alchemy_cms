# frozen_string_literal: true

require "rails_helper"
require "alchemy/configuration/list_option"

RSpec.describe Alchemy::Configuration::ListOption do
  describe ".item_class" do
    subject { described_class.item_class }

    it "raises NotImplementedError" do
      expect { subject }.to raise_exception(NotImplementedError)
    end
  end
end
