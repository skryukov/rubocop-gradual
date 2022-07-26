# frozen_string_literal: true

require "rubocop/gradual/rake_task"

RSpec.describe RuboCop::Gradual::RakeTask do
  before { Rake::Task.clear }

  after { Rake::Task.clear }

  describe "defining tasks" do
    it "creates a rubocop_gradual task and a rubocop_gradual autocorrect task" do
      described_class.new

      expect(Rake::Task.task_defined?(:rubocop_gradual)).to be true
      expect(Rake::Task.task_defined?("rubocop_gradual:autocorrect")).to be true
    end

    it "creates a named task and a named autocorrect task" do
      described_class.new(:lint_lib)

      expect(Rake::Task.task_defined?(:lint_lib)).to be true
      expect(Rake::Task.task_defined?("lint_lib:autocorrect")).to be true
    end

    it "creates a rubocop task and a rubocop autocorrect_all task" do
      described_class.new

      expect(Rake::Task.task_defined?(:rubocop_gradual)).to be true
      expect(Rake::Task.task_defined?("rubocop_gradual:autocorrect_all")).to be true
    end

    it "creates a named task and a named autocorrect_all task" do
      described_class.new(:lint_lib)

      expect(Rake::Task.task_defined?(:lint_lib)).to be true
      expect(Rake::Task.task_defined?("lint_lib:autocorrect_all")).to be true
    end
  end

  describe "running tasks" do
    before do
      $stdout = StringIO.new
      $stderr = StringIO.new
    end

    after do
      $stdout = STDOUT
      $stderr = STDERR
    end

    let!(:cli) do
      instance_double(RuboCop::Gradual::CLI, run: cli_result).tap do |cli|
        allow(RuboCop::Gradual::CLI).to receive(:new).and_return(cli)
      end
    end
    let(:cli_result) { 0 }

    it "runs with default options" do
      described_class.new

      Rake::Task["rubocop_gradual"].execute

      expect(cli).to have_received(:run).with([])
    end

    context "with specified options" do
      let(:rake_task) do
        described_class.new do |task|
          task.options = ["--display-time"]
          task.verbose = false
        end
      end

      it "runs with specified options" do
        rake_task
        Rake::Task["rubocop_gradual"].execute

        expect(cli).to have_received(:run).with(%w[--display-time])
      end
    end

    it "allows nested arrays inside options" do
      described_class.new do |task|
        task.options = [%w[--gradual-file custom_gradual_file.lock]]
      end

      Rake::Task["rubocop_gradual"].execute

      expect(cli).to have_received(:run).with(%w[--gradual-file custom_gradual_file.lock])
    end

    context "when cli returns non-zero" do
      let(:cli_result) { 1 }

      it "raises error" do
        described_class.new
        expect { Rake::Task["rubocop_gradual"].execute }.to raise_error(SystemExit)
      end
    end

    describe "autocorrect" do
      it "runs with --autocorrect" do
        described_class.new
        Rake::Task["rubocop_gradual:autocorrect"].execute

        expect(cli).to have_received(:run).with(["--autocorrect"])
      end

      it "runs with --autocorrect-all" do
        described_class.new
        Rake::Task["rubocop_gradual:autocorrect_all"].execute

        expect(cli).to have_received(:run).with(["--autocorrect-all"])
      end

      context "with specified options" do
        let(:rake_task) do
          described_class.new do |task|
            task.options = ["--debug"]
            task.verbose = false
          end
        end

        it "runs with specified options" do
          rake_task
          Rake::Task["rubocop_gradual:autocorrect_all"].execute

          expect(cli).to have_received(:run).with(%w[--autocorrect-all --debug])
        end
      end
    end

    describe "check" do
      it "runs with --check" do
        described_class.new

        Rake::Task["rubocop_gradual:check"].execute

        expect(cli).to have_received(:run).with(["--check"])
      end
    end

    describe "force_update" do
      it "runs with --force-update" do
        described_class.new

        Rake::Task["rubocop_gradual:force_update"].execute

        expect(cli).to have_received(:run).with(["--force-update"])
      end
    end
  end
end
