require 'spec_helper'
require 'ostruct'

describe Alchemy::MountPoint do

  describe '.get' do

    it "returns the path of alchemy's mount point" do
      allow(Alchemy::MountPoint).to receive(:mount_point).and_return('/cms')
      expect(Alchemy::MountPoint.get).to eq('/cms')
    end

    it "removes the leading slash if root mount point" do
      allow(Alchemy::MountPoint).to receive(:mount_point).and_return('/')
      expect(Alchemy::MountPoint.get).to eq('')
    end

    context "with remove_leading_slash_if_blank set to false" do
      before {
        allow(Alchemy::MountPoint).to receive(:mount_point).and_return('/')
      }

      it "does not remove the leading white slash of path" do
        expect(Alchemy::MountPoint.get(false)).to eq('/')
      end

      context "and with mount point not root" do
        before {
          allow(Alchemy::MountPoint).to receive(:mount_point).and_return('/cms')
        }

        it "does not remove the leading white slash of path" do
          expect(Alchemy::MountPoint.get(false)).to eq('/cms')
        end
      end
    end
  end

  describe '.routes' do
    it "returns the routes object from alchemy engine" do
      expect(Alchemy::MountPoint.routes).to be_instance_of(ActionDispatch::Journey::Route)
    end
  end

  describe '.mount_point' do
    it 'returns the raw mount point path from routes' do
      allow(Alchemy::MountPoint).to receive(:routes).and_return(OpenStruct.new(path: OpenStruct.new(spec: '/cms')))
      expect(Alchemy::MountPoint.mount_point).to eq('/cms')
    end

    context "Alchemy routes could not be found" do
      before {
        allow(Alchemy::MountPoint).to receive(:routes).and_return(nil)
      }

      it "falls back to root path" do
        expect(Alchemy::MountPoint.mount_point).to eq('/')
      end
    end
  end

end
