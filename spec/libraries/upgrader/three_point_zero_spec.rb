require 'spec_helper'
require 'alchemy/upgrader'

module Alchemy
  describe Upgrader::ThreePointZero do
    let(:upgrader) { Alchemy::Upgrader }

    # silence the logger
    before {
      upgrader.stub(:desc).and_return
      upgrader.stub(:log).and_return
    }

    describe '.rename_registered_role_into_member' do
      context "with registered user present" do
        before { FactoryGirl.create(:member_user) }

        it "converts all registered roles into member roles" do
          upgrader.send(:rename_registered_role_into_member)
          User.all.each do |user|
            expect(user.roles).to eq(['member'])
          end
        end

        it "does not convert other roles into member roles" do
          FactoryGirl.create(:admin_user, email: 'admin@show.com', login: 'admin')
          upgrader.send(:rename_registered_role_into_member)
          User.all.where('roles LIKE "%admin%"').each do |admin|
            expect(admin.roles).to eq(['admin'])
          end
        end
      end

      it "skips if no users found" do
        FactoryGirl.create(:author_user)
        upgrader.send(:rename_registered_role_into_member)
        User.all.each do |user|
          expect(user.roles).to eq(['author'])
        end
      end
    end

  end
end
