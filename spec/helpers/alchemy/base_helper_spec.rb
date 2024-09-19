# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe BaseHelper do
    describe "#render_icon" do
      subject { helper.render_icon(:info, options) }

      let(:options) { {} }

      it "renders an alchemy-icon with line style" do
        is_expected.to have_css 'alchemy-icon[name="information"][icon-style="line"]'
      end

      context "with options" do
        let(:options) { {style: "fill", size: "xl"} }

        it "renders an alchemy-icon with given options" do
          is_expected.to have_css 'alchemy-icon[name="information"][icon-style="fill"][size="xl"]'
        end
      end
    end

    describe "#render_message" do
      context "if no argument is passed" do
        it "should render an alchemy-message with an info icon and the given content" do
          expect(helper.render_message { content_tag(:p, "my notice") }).to eq <<~HTML
            <alchemy-message type="info">
              <p>my notice</p>
            </alchemy-message>
          HTML
        end
      end

      context "if an argument is passed" do
        it "should render the passed argument as the type for the message" do
          expect(helper.render_message(:error) { content_tag(:p, "my notice") }).to eq <<~HTML
            <alchemy-message type="error">
              <p>my notice</p>
            </alchemy-message>
          HTML
        end
      end
    end
  end
end
