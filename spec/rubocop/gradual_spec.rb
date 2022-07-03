# frozen_string_literal: true

RSpec.describe RuboCop::Gradual, :aggregate_failures do
  subject(:gradual_ci) { RuboCop::Gradual::CLI.new.run([*options, actual_lock_path]) }

  around do |example|
    Dir.mktmpdir do |tmpdir|
      tmpdir = File.realpath(tmpdir)
      project_path = File.join("spec/fixtures/project")
      FileUtils.cp_r(project_path, tmpdir)

      Dir.chdir(File.join(tmpdir, "project")) { example.run }
    end
  end

  before do
    $stdout = StringIO.new
    $stderr = StringIO.new
  end

  after do
    $stdout = STDOUT
    $stderr = STDERR
  end

  shared_examples "error with --ci option" do
    context "with --ci option" do
      let(:options) { super().unshift("--ci") }

      it "doesn't update file" do
        expect { gradual_ci }.not_to(
          change do
            File.exist?(actual_lock_path) && File.read(actual_lock_path, encoding: Encoding::UTF_8)
          end
        )
      end

      it "returns error" do
        expect(gradual_ci).to eq(1)
        expect($stdout.string).to include("Unexpected Changes!")
      end
    end
  end

  let(:options) { %w[--gradual-file] }

  let(:actual_lock_path) { File.expand_path("result.lock") }
  let(:actual_data) { File.read(actual_lock_path, encoding: Encoding::UTF_8) }

  let(:expected_lock_path) { File.expand_path("full.lock") }
  let(:expected_data) { File.read(expected_lock_path, encoding: Encoding::UTF_8) }

  it "writes full file for the first time" do
    expect(gradual_ci).to eq(0)
    expect(actual_data).to eq(expected_data)
    expect($stdout.string).to include("RuboCop Gradual got results for the first time. 22 issue(s) found.")
  end

  include_examples "error with --ci option"

  context "when the lock file is outdated" do
    let(:actual_lock_path) { File.expand_path("outdated.lock") }
    let(:expected_lock_path) { File.expand_path("full.lock") }

    it "updates file" do
      expect(gradual_ci).to eq(0)
      expect(actual_data).to eq(expected_data)
      expect($stdout.string).to include("RuboCop Gradual got its results updated.")
    end

    include_examples "error with --ci option"
  end

  context "when the lock file is the same" do
    let(:actual_lock_path) { expected_lock_path }

    it "returns success and doesn't update file" do
      expect(gradual_ci).to eq(0)
      expect(actual_data).to eq(expected_data)
      expect($stdout.string).to include("RuboCop Gradual got no changes.")
    end

    context "with --ci option" do
      let(:options) { super().unshift("--ci") }

      it "returns success and doesn't update file" do
        expect(gradual_ci).to eq(0)
        expect(actual_data).to eq(expected_data)
        expect($stdout.string).to include("RuboCop Gradual got no changes.")
      end
    end
  end

  context "when the lock file was better before" do
    let(:actual_lock_path) { File.expand_path("was_better.lock") }
    let(:expected_lock_path) { actual_lock_path }

    it "returns error and does not update file" do
      expect(gradual_ci).to eq(1)
      expect(actual_data).to eq(expected_data)
      expect($stdout.string).to include("Uh oh, RuboCop Gradual got worse:")
        .and include("app/controllers/books_controller.rb (2 new issues)")
    end

    context "with --ci option" do
      let(:options) { super().unshift("--ci") }

      it "returns error and does not update file" do
        expect(gradual_ci).to eq(1)
        expect(actual_data).to eq(expected_data)
        expect($stdout.string).to include("Uh oh, RuboCop Gradual got worse:")
          .and include("app/controllers/books_controller.rb (2 new issues)")
      end
    end

    context "with --update option" do
      let(:options) { super().unshift("--update") }
      let(:expected_lock_path) { File.expand_path("full.lock") }

      it "returns success and updates file" do
        expect(gradual_ci).to eq(0)
        expect(actual_data).to eq(expected_data)
        expect($stdout.string).to include("Uh oh, RuboCop Gradual got worse:")
          .and include("app/controllers/books_controller.rb (2 new issues)")
          .and include("Force updating lock file...")
      end
    end
  end

  context "when the lock file become better" do
    let(:actual_lock_path) { File.expand_path("was_worse.lock") }
    let(:expected_lock_path) { File.expand_path("full.lock") }

    it "updates file" do
      expect(gradual_ci).to eq(0)
      expect(actual_data).to eq(expected_data)
      expect($stdout.string).to include("RuboCop Gradual got 2 issue(s) fixed, 22 left. Keep going!")
    end

    include_examples "error with --ci option"
  end

  context "when no issues found" do
    let(:options) { %w[--only Security --gradual-file] }
    let(:actual_lock_path) { File.expand_path("full.lock") }

    it "removes file" do
      expect(gradual_ci).to eq(0)
      expect(File.exist?(actual_lock_path)).to be(false)
      expect($stdout.string).to include("RuboCop Gradual is complete!")
    end

    include_examples "error with --ci option"
  end
end
