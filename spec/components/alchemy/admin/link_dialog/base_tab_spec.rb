# frozen_string_literal: true

require "rails_helper"

class BaseTestTab < Alchemy::Admin::LinkDialog::BaseTab
  delegate :render_message, to: :helpers

  def self.panel_name
    :base_test
  end

  def title
    "Base Test Tab"
  end

  def fields
    [
      title_input,
      target_select
    ]
  end
end

RSpec.describe Alchemy::Admin::LinkDialog::BaseTab, type: :component do
  let(:is_selected) { false }
  let(:link_title) { nil }
  let(:link_target) { nil }

  before do
    render_inline(BaseTestTab.new("/foo", is_selected: is_selected, link_title: link_title, link_target: link_target))
  end

  it_behaves_like "a link dialog tab", :base_test, "Base Test Tab"
  it_behaves_like "a link dialog - target select", :base_test
end
