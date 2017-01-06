RSpec.shared_examples_for "having a json uploader error message" do
  it "renders json response with error message" do
    subject
    expect(response.content_type).to eq('application/json')
    expect(response.status).to eq(422)
    json = JSON.parse(response.body)
    expect(json).to have_key('growl_message')
    expect(json).to have_key('files')
  end
end
