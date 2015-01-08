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
    before do
      allow(File)
        .to receive(:read)
        .and_return("mount Alchemy::Engine => '/cms'")
    end

    it 'returns the mount point path from routes.' do
      expect(Alchemy::MountPoint.path).to eq('/cms')
    end

    context "Alchemy mount point could not be found" do
      before do
        allow(File)
        .to receive(:read)
        .and_return("")
      end

      it "raises an exception" do
        expect {
          Alchemy::MountPoint.path
        }.to raise_error
      end
    end

    context 'Mount point using double quotes string' do
      before do
        allow(File)
          .to receive(:read)
          .and_return('mount Alchemy::Engine => "/cms"')
      end

      it 'returns the mount point path from routes.' do
        expect(Alchemy::MountPoint.path).to eq('/cms')
      end
    end
  end
end
