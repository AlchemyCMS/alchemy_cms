require 'spec_helper'

describe Alchemy::MountPoint do
  describe '.get' do
    it "returns the path of alchemy's mount point" do
      allow(Alchemy::MountPoint).to receive(:path).and_return('/cms')
      expect(Alchemy::MountPoint.get).to eq('/cms')
    end

    it "removes the leading slash if root mount point" do
      allow(Alchemy::MountPoint).to receive(:path).and_return('/')
      expect(Alchemy::MountPoint.get).to eq('')
    end

    context "with remove_leading_slash_if_blank set to false" do
      before do
        allow(Alchemy::MountPoint)
          .to receive(:path)
          .and_return('/')
      end

      it "does not remove the leading white slash of path" do
        expect(Alchemy::MountPoint.get(false)).to eq('/')
      end

      context "and with mount point not root" do
        before do
          allow(Alchemy::MountPoint)
            .to receive(:path)
            .and_return('/cms')
        end

        it "does not remove the leading white slash of path" do
          expect(Alchemy::MountPoint.get(false)).to eq('/cms')
        end
      end
    end
  end

  describe '.path' do
    subject(:mount_path) { Alchemy::MountPoint.path }

    it 'returns the mount point for the dummy app' do
      expect(mount_path).to eq('/')
    end

    context 'not mounted' do
      before do
        allow(Rails.application.routes.routes).to receive(:find) { nil }
      end

      it 'raises an error' do
        expect { mount_path }.to raise_error(Alchemy::NotMountedError)
      end
    end
  end
end
