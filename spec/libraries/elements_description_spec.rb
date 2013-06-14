require 'spec_helper'

module Alchemy

  describe ElementsDescription do

    context "no description files are found" do

      before do
        FileUtils.mv(File.join(File.dirname(__FILE__), '../dummy/config/alchemy/elements.yml'), File.join(File.dirname(__FILE__), '../dummy/config/alchemy/elements.yml.bak'))
      end

      it "should raise an error" do
        expect { ElementsDescription.read_file }.to raise_error(LoadError)
      end

      after do
        FileUtils.mv(File.join(File.dirname(__FILE__), '../dummy/config/alchemy/elements.yml.bak'), File.join(File.dirname(__FILE__), '../dummy/config/alchemy/elements.yml'))
      end

    end

    context "without any descriptions in elements.yml file" do

      it "should return an empty array" do
        YAML.stub(:load_file).and_return(false) # Yes, YAML.load_file returns false if an empty file exists.
        ElementsDescription.read_file.should == []
      end

    end

  end

end
