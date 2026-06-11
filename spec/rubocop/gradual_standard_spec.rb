# frozen_string_literal: true

RSpec.describe RuboCop::Gradual, :aggregate_failures do
  subject(:gradual_cli) { RuboCop::Gradual::CLI.new.run([*options, lock_path]) }

  around do |example|
    Dir.mktmpdir do |tmpdir|
      tmpdir = File.realpath(tmpdir)
      FileUtils.cp_r(File.join("spec/fixtures/standard_project"), tmpdir)

      Dir.chdir(File.join(tmpdir, "standard_project")) do
        RuboCop::PathUtil.reset_pwd if RuboCop::PathUtil.respond_to?(:reset_pwd)
        example.run
      end
    end
  end

  before do
    require "standard"
    $stdout = StringIO.new
    $stderr = StringIO.new
  rescue LoadError
    skip "the standard gem is not installed"
  end

  after do
    $stdout = STDOUT
    $stderr = STDERR
  end

  let(:options) { %w[--standard --gradual-file] }
  let(:lock_path) { File.expand_path("result.lock") }

  it "lints with the Standard ruleset" do
    expect(gradual_cli).to eq(0)
    expect(File.read(lock_path)).to include("Style/StringLiterals")
    expect($stdout.string).to include("RuboCop Gradual got results for the first time. 1 issue(s) found.")
  end

  context "with --autocorrect option" do
    let(:options) { %w[--standard --autocorrect --gradual-file] }

    it "fixes offenses and removes the lock file" do
      expect(gradual_cli).to eq(0)
      expect(File.read("lib/example.rb")).to include('puts "single"')
      expect(File.exist?(lock_path)).to be(false)
    end
  end
end
