# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe Admin::ContentsController do
    before do
      authorize_user(:as_admin)
    end

    context 'with element_id parameter' do
      describe '#create' do
        let(:element) { create(:alchemy_element, name: 'headline') }

        it "creates a content from name" do
          expect {
            post admin_contents_path(content: {element_id: element.id, name: 'headline'}, format: :js)
          }.to change { Alchemy::Content.count }.by(1)
        end

        it "creates a content from essence_type" do
          expect {
            post admin_contents_path(
              content: {
                element_id: element.id, essence_type: 'EssencePicture'
              },
              format: :js
            )
          }.to change { Alchemy::Content.count }.by(1)
        end
      end
    end
  end
end
