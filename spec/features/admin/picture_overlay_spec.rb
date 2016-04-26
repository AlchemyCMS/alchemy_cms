require 'spec_helper'

RSpec.feature "Picture overlay" do
  before do
    authorize_user(:as_admin)
  end

  let(:element) { create(:alchemy_element) }

  describe "Upload button" do
    let(:options) do
      {grouped: true}
    end

    scenario 'passes options params to the uploader script' do
      visit alchemy.admin_pictures_path(element_id: element.id, options: options)

      expect(page.find('form#new_picture + script').text).to \
        match /#{Regexp.escape({options: options}.to_param)}/
    end
  end

  describe "assigning an image" do
    let!(:picture) { create(:alchemy_picture) }

    context 'when no content is present' do
      scenario 'it has link to create a content' do
        visit alchemy.admin_pictures_path(element_id: element.id)
        expect(page).to have_selector('a[data-method="post"][href*="/admin/contents"]')
      end
    end
  end
end
