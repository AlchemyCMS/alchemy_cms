require "rails_helper"
require "alchemy/install/tasks"

RSpec.describe Alchemy::Install::Tasks do
  let(:tasks) { described_class.new }

  describe "#inject_routes" do
    subject { tasks.inject_routes(auto_accept) }

    before do
      allow(File).to receive(:read).and_return(routes_content)
      allow(tasks).to receive(:inject_into_file)
    end

    context "with auto_accept" do
      let(:auto_accept) { true }

      context "when routes are already mounted" do
        let(:routes_content) { "mount Alchemy::Engine" }

        it "does not inject the routes" do
          subject
          expect(tasks).not_to have_received(:inject_into_file)
        end
      end

      context "when routes are not mounted" do
        let(:routes_content) { "get '/home', to: 'home#index'" }

        it "injects the routes" do
          subject
          expect(tasks).to have_received(:inject_into_file).with(
            "./config/routes.rb",
            "\n  mount Alchemy::Engine => '/'\n",
            {
              after: Alchemy::Install::Tasks::SENTINEL,
              verbose: true
            }
          )
        end
      end
    end

    context "without auto_accept" do
      let(:auto_accept) { false }

      before do
        allow(tasks).to receive(:ask).and_return("/cms")
      end

      context "when routes are already mounted" do
        let(:routes_content) { "mount Alchemy::Engine" }

        it "does not inject the routes" do
          subject
          expect(tasks).not_to have_received(:inject_into_file)
        end
      end

      context "when routes are not mounted" do
        let(:routes_content) { "get '/home', to: 'home#index'" }

        it "injects mountpoint into the routes" do
          subject
          expect(tasks).to have_received(:inject_into_file).with(
            "./config/routes.rb",
            "\n  mount Alchemy::Engine => '/cms'\n",
            {
              after: Alchemy::Install::Tasks::SENTINEL,
              verbose: true
            }
          )
        end
      end
    end
  end
end
