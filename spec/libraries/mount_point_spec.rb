require 'spec_helper'
require 'ostruct'

describe Alchemy::MountPoint do

  describe '.get' do

    it "returns the path of alchemy's mount point" do
      Alchemy::MountPoint.stub(:mount_point).and_return('/cms')
      Alchemy::MountPoint.get.should == '/cms'
    end

    it "removes the leading slash if root mount point" do
      Alchemy::MountPoint.stub(:mount_point).and_return('/')
      Alchemy::MountPoint.get.should == ''
    end

    context "with remove_leading_slash_if_blank set to false" do
      before {
        Alchemy::MountPoint.stub(:mount_point).and_return('/')
      }

      it "does not remove the leading white slash of path" do
        Alchemy::MountPoint.get(false).should == '/'
      end

      context "and with mount point not root" do
        before {
          Alchemy::MountPoint.stub(:mount_point).and_return('/cms')
        }

        it "does not remove the leading white slash of path" do
          Alchemy::MountPoint.get(false).should == '/cms'
        end
      end
    end
  end

  describe '.routes' do
    it "returns the routes object from alchemy engine" do
      Alchemy::MountPoint.routes.should be_instance_of(ActionDispatch::Journey::Route)
    end
  end

  describe '.mount_point' do
    it 'returns the raw mount point path from routes' do
      Alchemy::MountPoint.stub(:routes).and_return(OpenStruct.new(path: OpenStruct.new(spec: '/cms')))
      Alchemy::MountPoint.mount_point.should == '/cms'
    end

    context "Alchemy routes could not be found" do
      before {
        Alchemy::MountPoint.stub(:routes).and_return(nil)
      }

      it "falls back to root path" do
        Alchemy::MountPoint.mount_point.should == '/'
      end
    end
  end

end
