# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe EssenceFile do
    let(:attachment) { create(:alchemy_attachment) }
    let(:essence)    { EssenceFile.new(attachment: attachment) }

    it_behaves_like "an essence" do
      let(:essence)          { EssenceFile.new }
      let(:ingredient_value) { attachment }
    end

    describe '#attachment_url' do
      subject { essence.attachment_url }

      it "returns the download attachment url." do
        is_expected.to match(/\/attachment\/#{attachment.id}\/download\/#{attachment.urlname}\.#{attachment.suffix}/)
      end

      context 'without attachment assigned' do
        let(:attachment) { nil }

        it { is_expected.to be_nil }
      end
    end

    describe '#preview_text' do
      it "returns the attachment's name as preview text" do
        expect(essence.preview_text).to eq(attachment.name)
      end

      context "with no attachment assigned" do
        it "returns empty string" do
          essence.attachment = nil
          expect(essence.preview_text).to eq('')
        end
      end
    end
  end
end
