require 'spec_helper'

module Alchemy
  describe I18n do
    describe '.translation_files' do
      subject { I18n.translation_files }
      it      { should be_a Array }
      it      { should be_any { |f| f =~ /alchemy.*.yml/ } }
    end

    describe '.available_locales' do
      subject { I18n.available_locales }
      before  { I18n.stub(translation_files: ['alchemy.kl.yml']) }
      it      { should be_a Array }
      it      { should include :kl }

      context 'when locales are already set in @@available_locales' do
        before { I18n.class_variable_set(:@@available_locales, [:kl, :jp]) }
        it     { should eq([:kl, :jp]) }
      end
    end

    describe '.available_locales=' do
      it "assigns the given locales to @@available_locales" do
        I18n.available_locales = [:kl, :nl, :cn]
        expect(I18n.class_variable_get(:@@available_locales)).to eq([:kl, :nl, :cn])
      end
    end
  end
end
