# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Content Security Policy" do
  before { authorize_user(:as_admin) }

  around do |example|
    configured = Alchemy.config.raw_admin_content_security_policy
    example.run
    Alchemy.config.admin_content_security_policy = configured
  end

  def policy = response.headers["Content-Security-Policy"]

  it "is applied by default" do
    get alchemy.admin_dashboard_path
    expect(policy).to be_present
  end

  it "is not applied when set to nil" do
    Alchemy.config.admin_content_security_policy = nil
    get alchemy.admin_dashboard_path
    expect(policy).to be_nil
  end

  it "declares script-src explicitly so the nonce is added to it" do
    get alchemy.admin_dashboard_path
    expect(policy).to match(/script-src [^;]*'nonce-/)
  end

  it "allows inline style attributes, which cannot carry a nonce" do
    get alchemy.admin_dashboard_path
    expect(policy).to include("style-src-attr 'unsafe-inline'")
  end

  it "nonces every inline script it renders" do
    get alchemy.admin_dashboard_path
    nonce = policy[/'nonce-([^']+)'/, 1]
    inline_scripts = response.body.scan(/<script(?![^>]*\ssrc=)[^>]*>/)
    expect(inline_scripts).to all(include(%(nonce="#{nonce}")))
  end

  it "exposes the nonce to Turbo through the meta tag" do
    get alchemy.admin_dashboard_path
    nonce = policy[/'nonce-([^']+)'/, 1]
    expect(response.body).to include(%(<meta name="csp-nonce" content="#{nonce}"))
  end

  it "allows modules that are pinned to a CDN" do
    Alchemy.importmap.pin "flatpickr/de", to: "https://ga.jspm.io/npm:flatpickr/de.js"
    get alchemy.admin_dashboard_path
    expect(policy).to match(%r{script-src [^;]*https://ga\.jspm\.io})
  ensure
    Alchemy.importmap.packages.delete("flatpickr/de")
  end

  it "allows admin stylesheets served from another host" do
    Alchemy.config.admin_stylesheets.add("https://cdn.example.com/admin.css")
    get alchemy.admin_dashboard_path
    expect(policy).to match(%r{style-src [^;]*https://cdn\.example\.com})
  ensure
    Alchemy.config.admin_stylesheets.delete("https://cdn.example.com/admin.css")
  end

  it "takes the nonce generator from the policy class" do
    stub_const("FixedNoncePolicy", Class.new(Alchemy::Admin::ContentSecurityPolicy) do
      def nonce_generator = ->(_request) { "fixed-nonce" }
    end)
    Alchemy.config.admin_content_security_policy = "FixedNoncePolicy"
    get alchemy.admin_dashboard_path
    expect(policy).to include("'nonce-fixed-nonce'")
  end

  describe "asset host" do
    around do |example|
      host = ActionController::Base.asset_host
      example.run
      ActionController::Base.asset_host = host
    end

    it "allows a plain asset host" do
      ActionController::Base.asset_host = "https://assets.example.com"
      get alchemy.admin_dashboard_path
      expect(policy).to match(%r{script-src [^;]*https://assets\.example\.com})
    end

    it "expands a sharded asset host" do
      ActionController::Base.asset_host = "https://assets%d.example.com"
      get alchemy.admin_dashboard_path
      expect(policy).to include("https://assets0.example.com", "https://assets3.example.com")
    end

    it "evaluates an asset host proc" do
      ActionController::Base.asset_host = ->(_source) { "https://from-proc.example.com" }
      get alchemy.admin_dashboard_path
      expect(policy).to match(%r{script-src [^;]*https://from-proc\.example\.com})
    end

    it "passes the request to a proc that asks for it" do
      ActionController::Base.asset_host = ->(_source, request) { "https://#{request.host}" }
      get alchemy.admin_dashboard_path
      expect(policy).to match(%r{script-src [^;]*https://www\.example\.com})
    end

    it "raises a helpful error instead of dropping an unusable host" do
      ActionController::Base.asset_host = "https://exa mple.com"
      expect { get alchemy.admin_dashboard_path }
        .to raise_error(Alchemy::Admin::ContentSecurityPolicy::InvalidSourceError, /asset host/)
    end
  end

  it "sends it report only when the policy class says so" do
    stub_const("ReportOnlyPolicy", Class.new(Alchemy::Admin::ContentSecurityPolicy) do
      def report_only? = true
    end)
    Alchemy.config.admin_content_security_policy = "ReportOnlyPolicy"
    get alchemy.admin_dashboard_path
    expect(policy).to be_nil
    expect(response.headers["Content-Security-Policy-Report-Only"]).to be_present
  end

  it "uses the configured class, so it can be replaced" do
    stub_const("CustomPolicy", Class.new(Alchemy::Admin::ContentSecurityPolicy) do
      def call = super.tap { _1.frame_src :self, "https://preview.example.com" }
    end)
    Alchemy.config.admin_content_security_policy = "CustomPolicy"
    get alchemy.admin_dashboard_path
    expect(policy).to include("frame-src 'self' https://preview.example.com")
  end

  it "never replaces a policy the host application configured" do
    host_policy = ActionDispatch::ContentSecurityPolicy.new { |p| p.default_src :https }
    allow_any_instance_of(ActionDispatch::Request)
      .to receive(:content_security_policy).and_return(host_policy)
    get alchemy.admin_dashboard_path
    expect(policy).to eq("default-src https:")
  end
end
