# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe PageMutex do
    it { is_expected.to belong_to(:page).optional }

    let(:page) { create(:alchemy_page) }
    let(:page_mutex_active) { described_class.create(page: page, created_at: 2.minutes.ago) }
    let(:page_mutex_expired) { described_class.create(page: page, created_at: 6.minutes.ago) }

    describe "#expired" do
      it "should not have expired mutexes if one is active" do
        page_mutex_active
        expect(PageMutex.expired).to be_empty
      end

      it "should have expired mutexes if one is older than 5 minutes" do
        page_mutex_expired
        expect(PageMutex.expired.count).to eq(1)
      end
    end

    describe "#with_lock!" do
      context "without page" do
        it "fires an argument error" do
          expect { described_class.with_lock!(nil) }.to raise_error(ArgumentError)
        end
      end

      context "without a lock" do
        it "executes the block" do
          expect { |block|
            described_class.with_lock!(page, &block)
          }.to yield_control.once
        end

        it "executes the block multiple times (sequentially)" do
          expect { |block|
            described_class.with_lock!(page, &block)
            described_class.with_lock!(page, &block)
          }.to yield_control.twice
        end

        it "return the result of the block" do
          expect(described_class.with_lock!(page) { "foo" }).to eq("foo")
        end
      end

      context "with a look" do
        it "should not run in parallel and raise an exception" do
          described_class.with_lock!(page) do
            expect { |block|
              described_class.with_lock!(page, &block)
            }.to raise_error Alchemy::PageMutex::LockFailed
          end
        end

        it "should not run if an entry is already in the database" do
          page_mutex_active
          expect { |block|
            described_class.with_lock!(page, &block)
          }.to raise_error Alchemy::PageMutex::LockFailed
        end

        it "should allow multiple mutexes for different pages" do
          described_class.with_lock!(create(:alchemy_page)) do
            expect { |block|
              described_class.with_lock!(page, &block)
            }.to yield_control.once
          end
        end
      end

      context "with an expired lock" do
        it "should run if database entry is expired" do
          page_mutex_expired
          expect { |block|
            described_class.with_lock!(page, &block)
          }.to yield_control.once
        end
      end
    end
  end
end
