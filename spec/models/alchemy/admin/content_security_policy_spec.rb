# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::ContentSecurityPolicy do
  describe "#nonce_generator" do
    subject(:nonce_generator) { described_class.new.nonce_generator }

    it "generates an unguessable nonce" do
      expect(SecureRandom).to receive(:base64).with(16).and_return("random-nonce")
      expect(nonce_generator.call(nil)).to eq("random-nonce")
    end

    # A session wide nonce would be the only way to let an inline script
    # survive a Turbo visit. We do not render any, so the nonce stays scoped
    # to the response that carried it.
    it "generates a new nonce for every request" do
      expect(nonce_generator.call(nil)).to_not eq(nonce_generator.call(nil))
    end
  end
end
