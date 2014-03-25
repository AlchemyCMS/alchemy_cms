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
          'adapter'  => 'mysql2',
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

    describe "#database_dump_command" do
      subject { Foo.database_dump_command(adapter) }

      context "when config for RAILS_ENV not found" do
        let(:adapter) { 'mysql2' }

        before { Foo.stub(environment: 'huh?') }

        it "should raise an error" do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context "when given a not supported database adapter" do
        let(:adapter) { 'oracle' }

        it "should raise an error" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context "for mysql adapter" do
        let(:adapter) { 'mysql2' }

        it "uses the mysqldump command" do
          should include('mysqldump ')
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
      end

      context "for postgresql adapter" do
        let(:adapter) { 'postgresql' }

        it "uses the pg_dump command with clean option" do
          should include('pg_dump --clean')
        end

        context "when a username is set in the config file" do
          it { should include("--username='testuser'") }
        end

        context "when a password is set in the config file" do
          it { should include("PGPASSWORD='123456'") }
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
      end

      after do
        Foo.instance_variable_set("@database_config", nil) # resets the memoization
      end
    end

    describe "#database_import_command" do
      subject { Foo.database_import_command(adapter) }

      context "when config for RAILS_ENV not found" do
        let(:adapter) { 'mysql' }

        before { Foo.stub(environment: 'huh?') }

        it "should raise an error" do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context "when given a not supported database adapter" do
        let(:adapter) { 'oracle' }

        it "should raise an error" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context "for mysql adapter" do
        let(:adapter) { 'mysql' }

        it "uses the mysql command" do
          should include('mysql ')
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
      end

      context "for postgresql adapter" do
        let(:adapter) { 'postgresql' }

        it "uses the psql command" do
          should include('psql ')
        end

        context "when a username is set in the config file" do
          it { should include("--username='testuser'") }
        end

        context "when a password is set in the config file" do
          it { should include("PGPASSWORD='123456'") }
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
      end

      after do
        Foo.instance_variable_set("@database_config", nil) # resets the memoization
      end
    end

    describe "#database_config" do
      it "should memoize the results" do
        expect(Foo.database_config).to eq(config['test'])
        config['username'] = 'newuser'
        expect(Foo.database_config).to eq(config['test'])
      end

      context 'for missing database config file' do
        before { File.stub(exists?: false) }

        it "raises error" do
          expect { Foo.database_config }.to raise_error(RuntimeError)
        end
      end
    end

  end
end
