require 'open3'

RSpec.describe 'command line invocation' do
  let(:command) { ['bundle', 'exec', 'bin/coconductor', 'help'] }
  let(:arguments) { [] }
  let(:output) do
    Dir.chdir project_root do
      Open3.capture3(*[command, arguments].flatten)
    end
  end
  let(:parsed_output) { YAML.safe_load(stdout) }
  let(:stdout) { output[0] }
  let(:stderr) { output[1] }
  let(:status) { output[2] }

  it 'Returns a zero exit code' do
    expect(status.exitstatus).to eql(0)
  end

  it 'returns the help text' do
    expect(stdout).to include('Coconductor commands:')
  end
end
