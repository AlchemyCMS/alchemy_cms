# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Alchemy::Admin::PicturesController" do
  describe "get /admin/pictures/:id/url" do
    let(:picture) { create(:alchemy_picture) }

    context "as anonymous user" do
      it "redirects" do
        get alchemy.url_admin_picture_path(picture)
        expect(response).to redirect_to(Alchemy.login_path)
      end
    end

    context "as author" do
      before do
        authorize_user(:as_author)
      end

      it "returns the url to picture" do
        get alchemy.url_admin_picture_path(picture)
        json = JSON.parse(response.body)
        expect(json).to match({
          "url" => /\/pictures\/.+\/image\.png/,
          "alt" => picture.name,
          "title" => Alchemy.t(:image_name, name: picture.name),
        })
      end

      context "with rendering params" do
        before do
          expect(Alchemy::Picture).to receive(:find) { picture }
        end

        let(:params) do
          {
            crop: true,
            crop_from: "0x0",
            crop_size: "300x300",
            flatten: true,
            format: "jpg",
            quality: "70",
            size: "100x100",
            upsample: false,
          }
        end

        it "returns the url to transformed picture" do
          expect(picture).to receive(:url).with(params)
          get alchemy.url_admin_picture_path(picture, params)
        end

        context "with forbidden rendering params" do
          let(:params) do
            {
              hack: "me",
            }
          end

          it "removes not allowed transformation params" do
            expect(picture).to receive(:url).with({})
            get alchemy.url_admin_picture_path(picture, params)
          end
        end
      end
    end
  end
end
