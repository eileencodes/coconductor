RSpec.describe 'integration test' do
  [
    Coconductor::Projects::FSProject,
    #  Coconductor::Projects::GitProject
  ].each do |project_type|
    context "with a #{project_type} project" do
      let(:filename) { 'CODE_OF_CONDUCT.txt' }
      let(:project_path) { fixture_path(fixture) }
      let(:git_path) { File.expand_path('.git', project_path) }
      let(:arguments) { {} }
      let(:cc_1_4) do
        Coconductor::CodeOfConduct.find('contributor-covenant/version/1/4')
      end

      subject { project_type.new(project_path, arguments) }

      context 'fixtures' do
        context 'contributor covenant 1.4' do
          let(:fixture) { 'contributor-covenant-1-4' }

          it 'matches' do
            expect(subject.code_of_conduct).to eql(cc_1_4)
          end
        end

        context 'no code of conduct' do
          let(:fixture) { 'no-coc' }

          it 'matches' do
            expect(subject.code_of_conduct).to be_nil
          end
        end

        context '.github folder' do
          let(:fixture) { 'dot-github-folder' }

          it 'matches' do
            expect(subject.code_of_conduct).to eql(cc_1_4)
          end
        end

        context 'docs folder' do
          let(:fixture) { 'docs-folder' }

          it 'matches' do
            expect(subject.code_of_conduct).to eql(cc_1_4)
          end
        end
      end
    end
  end
end