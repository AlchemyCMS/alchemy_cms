require 'spec_helper'

RSpec.feature "Picture overlay" do
  before do
    authorize_user(:as_admin)
  end

  describe "Upload button" do
    let(:element) { create(:alchemy_element) }

    let(:options) do
      {grouped: true}
    end

    scenario 'passes options params to the uploader script' do
      visit alchemy.admin_pictures_path(element_id: element.id, options: options)

      expect(page.find('form#new_picture + script').text).to \
        match /#{Regexp.escape({options: options}.to_param)}/
    end
  end
end
