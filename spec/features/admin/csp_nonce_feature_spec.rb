# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Content Security Policy", type: :system, js: true do
  let!(:default_site) { create(:alchemy_site) }

  before { authorize_user(:as_editor) }

  # Turbo renders into the document of the first page load, so the browser
  # keeps enforcing the policy that came with it while Turbo re-activates the
  # scripts of every body and head it renders afterwards, under the nonce of
  # the response they came from. Nothing we render may depend on that nonce.
  it "is not violated by a Turbo visit" do
    visit "/admin"
    expect(page).to have_selector("body.dashboard.index")

    page.execute_script(<<~JS)
      window.cspViolations = []
      document.addEventListener("securitypolicyviolation", (event) =>
        window.cspViolations.push(`${event.violatedDirective} ${event.blockedURI}`))
    JS

    click_on "Languages"
    expect(page).to have_selector("body.languages.index")

    expect(page.evaluate_script("window.cspViolations")).to eq([])
  end
end
