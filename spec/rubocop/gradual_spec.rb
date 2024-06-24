# frozen_string_literal: true

RSpec.describe RuboCop::Gradual, :aggregate_failures do
  subject(:gradual_cli) { RuboCop::Gradual::CLI.new.run([*options, actual_lock_path]) }

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

  shared_examples "error with --check option" do |with_extended_steps: true|
    context "with --check option" do
      let(:options) { super().unshift("--check") }

      it "doesn't update file" do
        expect { gradual_cli }.not_to(
          change do
            File.exist?(actual_lock_path) && File.read(actual_lock_path, encoding: Encoding::UTF_8)
          end
        )
      end

      it "returns error" do
        expect(gradual_cli).to eq(1)
        expect($stdout.string).to include("Unexpected Changes!")
          .and(with_extended_steps ? include("EVEN BETTER") : not_include("EVEN BETTER"))
      end
    end
  end

  let(:options) { %w[--gradual-file] }

  let(:actual_lock_path) { File.expand_path("result.lock") }
  let(:actual_data) { File.read(actual_lock_path, encoding: Encoding::UTF_8) }

  let(:expected_lock_path) { File.expand_path("full.lock") }
  let(:expected_data) { File.read(expected_lock_path, encoding: Encoding::UTF_8) }

  it "writes full file for the first time" do
    expect(gradual_cli).to eq(0)
    expect(actual_data).to eq(expected_data)
    expect($stdout.string).to include("RuboCop Gradual got results for the first time. 22 issue(s) found.")
  end

  include_examples "error with --check option"

  context "when the lock file is outdated" do
    let(:actual_lock_path) { File.expand_path("outdated.lock") }
    let(:expected_lock_path) { File.expand_path("full.lock") }

    it "updates file" do
      expect(gradual_cli).to eq(0)
      expect(actual_data).to eq(expected_data)
      expect($stdout.string).to include("RuboCop Gradual got its results updated.")
    end

    include_examples "error with --check option"
  end

  context "when the lock file is outdated but only by file hash" do
    let(:actual_lock_path) { File.expand_path("outdated_file.lock") }
    let(:expected_lock_path) { File.expand_path("full.lock") }

    it "updates file" do
      expect(gradual_cli).to eq(0)
      expect(actual_data).to eq(expected_data)
      expect($stdout.string).to include("RuboCop Gradual got its results updated.")
    end

    include_examples "error with --check option"
  end

  context "when the lock file is the same" do
    let(:actual_lock_path) { expected_lock_path }

    it "returns success and doesn't update file" do
      expect(gradual_cli).to eq(0)
      expect(actual_data).to eq(expected_data)
      expect($stdout.string).to include("RuboCop Gradual got no changes.")
    end

    context "with --check option" do
      let(:options) { super().unshift("--check") }

      it "returns success and doesn't update file" do
        expect(gradual_cli).to eq(0)
        expect(actual_data).to eq(expected_data)
        expect($stdout.string).to include("RuboCop Gradual got no changes.")
      end
    end
  end

  context "when the lock file was better before" do
    let(:actual_lock_path) { File.expand_path("was_better.lock") }
    let(:expected_lock_path) { actual_lock_path }

    it "returns error and does not update file" do
      expect(gradual_cli).to eq(1)
      expect(actual_data).to eq(expected_data)
      expect($stdout.string).to include("Uh oh, RuboCop Gradual got worse:")
        .and include("app/controllers/books_controller.rb (2 new issues)")
    end

    context "with --check option" do
      let(:options) { super().unshift("--check") }

      it "returns error and does not update file" do
        expect(gradual_cli).to eq(1)
        expect(actual_data).to eq(expected_data)
        expect($stdout.string).to include("Uh oh, RuboCop Gradual got worse:")
          .and include("app/controllers/books_controller.rb (2 new issues)")
      end
    end

    context "with --force-update option" do
      let(:options) { super().unshift("--force-update") }
      let(:expected_lock_path) { File.expand_path("full.lock") }

      it "returns success and updates file" do
        expect(gradual_cli).to eq(0)
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
      expect(gradual_cli).to eq(0)
      expect(actual_data).to eq(expected_data)
      expect($stdout.string).to include("RuboCop Gradual got 2 issue(s) fixed, 22 left. Keep going!")
    end

    include_examples "error with --check option", with_extended_steps: false
  end

  context "when no issues found" do
    let(:options) { %w[--config security_only_rubocop.yml --gradual-file] }
    let(:actual_lock_path) { File.expand_path("full.lock") }

    it "removes file" do
      expect(gradual_cli).to eq(0)
      expect(File.exist?(actual_lock_path)).to be(false)
      expect($stdout.string).to include("RuboCop Gradual is complete!")
    end

    include_examples "error with --check option", with_extended_steps: false
  end

  context "with --autocorrect option" do
    let(:options) { %w[--autocorrect --gradual-file] }
    let(:actual_lock_path) { File.expand_path("full.lock") }
    let(:expected_lock_path) { File.expand_path("autocorrected.lock") }

    it "updates file" do
      expect(gradual_cli).to eq(0)
      expect(actual_data).to eq(expected_data)
      expect($stdout.string).to include("Inspecting 3 file(s) for autocorrection...")
        .and include("Fixed 2 file(s).")
        .and include("RuboCop Gradual got 13 issue(s) fixed, 9 left. Keep going!")
    end
  end

  context "with --list option" do
    let(:options) { %w[--list --gradual-file] }

    it "lists project files" do
      expect(gradual_cli).to eq(1)
      expect($stdout.string.split("\n")).to match_array(Dir.glob("**/*.rb"))
    end

    context "with --autocorrect option" do
      let(:options) { %w[--list --autocorrect --gradual-file] }

      it "lists project files" do
        expect(gradual_cli).to eq(1)
        expect($stdout.string.split("\n")).to match_array(Dir.glob("**/*.rb"))
      end
    end

    context "with --autocorrect option without changes" do
      let(:options) { %w[--list --autocorrect --gradual-file] }
      let(:actual_lock_path) { File.expand_path("full.lock") }

      it "lists project files" do
        expect(gradual_cli).to eq(1)
        expect($stdout.string).to eq("")
      end
    end

    context "with --autocorrect option and outdated lock file" do
      let(:options) { %w[--list --autocorrect --gradual-file] }
      let(:actual_lock_path) { File.expand_path("outdated.lock") }

      it "lists project files" do
        expect(gradual_cli).to eq(1)
        expect($stdout.string).to eq("app/controllers/books_controller.rb\n")
      end
    end
  end
end
