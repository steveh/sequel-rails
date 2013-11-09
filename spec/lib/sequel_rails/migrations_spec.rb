require "spec_helper"
require "fakefs/spec_helpers"

describe SequelRails::Migrations do
  let!(:db) { ::Sequel::Model.db }

  [:migrate_up!, :migrate_down!].each do |migration_method|
    describe ".#{migration_method}" do
      let(:result) { double(:result) }
      context "with no version specified" do
        let(:opts) { {} }
        it "runs migrations using Sequel::Migrator" do
          expect(::Sequel::Migrator).to receive(:run).with(
            db, Rails.root.join("db/migrate"), opts
          ).and_return result
          expect(described_class.send(migration_method)).to be result
        end
      end
      context "with version specified" do
        let(:opts) { {:target => 1} }
        it "runs migrations using Sequel::Migrator" do
          expect(::Sequel::Migrator).to receive(:run).with(
            db, Rails.root.join("db/migrate"), opts
          ).and_return result
          expect(described_class.send(migration_method, 1)).to be result
        end
      end
    end
  end

  describe ".pending_migrations?" do
    include FakeFS::SpecHelpers
    let(:path) { Rails.root.join("db/migrate") }

    it "returns false if no db/migrate directory exists" do
      expect(described_class.pending_migrations?).to be_false
    end

    it "returns false if db/migrate directory exists, but is empty" do
      FileUtils.mkdir_p path
      expect(described_class.pending_migrations?).to be_false
    end

    context "when db/migrate directory exists and contains migrations" do
      before do
        FileUtils.mkdir_p path
        FileUtils.touch(File.join(path, 'test_migration.rb'))
      end

      it "returns true if any pending migration" do
        expect(::Sequel::Migrator).to receive(:is_current?).with(
          db, Rails.root.join("db/migrate")
        ).and_return false
        expect(described_class.pending_migrations?).to be_true
      end

      it "returns false if no pending migration" do
        expect(::Sequel::Migrator).to receive(:is_current?).with(
          db, Rails.root.join("db/migrate")
        ).and_return true
        expect(described_class.pending_migrations?).to be_false
      end
    end
  end
end
