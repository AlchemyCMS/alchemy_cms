# frozen_string_literal: true

require "rails_helper"
require "benchmark"

RSpec.describe Alchemy::Page::Publisher do
  describe "#publish!" do
    let!(:pages) do
      (0..10).map do
        page = create(:alchemy_page, autogenerate_elements: true)
        create(:alchemy_element, page_version: page.draft_version, parent_element: page.draft_version.elements.first)
        page
      end
    end

    it "is slow" do
      result = Benchmark.measure do
        pages.each { |page| described_class.new(page).publish!(public_on: Time.current) }
      end
      puts result
    end
  end
end
