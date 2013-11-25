require 'spec_helper'
require 'alchemy/tasks/helpers'

module Alchemy

  class Foo
    extend Tasks::Helpers
  end

  describe "Tasks:Helpers" do

    let(:config) do
      {
        'test' => {
          'username' => 'testuser',
          'password' => '123456',
          'host'     => 'localhost'
        }
      }
    end

    before do
      File.stub(exists?: true)
      YAML.stub(load_file: config)
    end

    describe "#mysql_credentials" do

      subject { Foo.mysql_credentials }

      after do
        Foo.instance_variable_set("@database_config", nil) # resets the memoization
      end

      context "when a username is set in the config file" do
        it { should include("--user='testuser'") }
      end

      context "when a password is set in the config file" do
        it { should include("--password='123456'") }
      end

      context "when a host is set in the config file" do
        context "and the host is localhost" do
          it { should_not include("--host=") }
        end

        context "and the host is anything but not localhost" do
          before do
            YAML.stub(load_file: {'test' => {'host' => 'mydomain.com'}})
          end
          it { should include("--host='mydomain.com'") }
        end
      end

      context "when config for RAILS_ENV not found" do
        before { Foo.stub(environment: 'huh?') }
        it "should raise an error" do
          expect{Foo.mysql_credentials}.to raise_error(RuntimeError)
        end
      end
    end

    describe "#database_config" do
      it "should memoize the results" do
        expect(Foo.database_config).to eq(config['test'])
        config['username'] = 'newuser'
        expect(Foo.database_config).to eq(config['test'])
      end
    end

  end
end
