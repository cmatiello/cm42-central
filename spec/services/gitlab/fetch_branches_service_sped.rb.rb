require 'rails_helper'

describe Gitlab::FetchBranchesService do
  let(:integrations) { double(:integrations) }
  let(:gitlab_integration) do
    instance_double(
      Integration,
      data: { 'url' => 'url', 'token' => 'token', 'project_id' => 1}
    )
  end
  let(:project) { instance_double(Project, integrations: integrations) }

  describe '#fetch' do
    before do
      allow(integrations).to receive(:find_by).with(kind: 'gitlab').and_return(gitlab_integration)
      allow(GitlabApi::FetchProjects).to receive(:perform).with('url', 'token', 1).and_return(response)
    end

    subject { described_class.new(project).fetch }

    context 'when it succeeds' do
      let(:response) { double(:response, success?: true) }

      it 'returns true' do
        is_expected.to be_truthy
      end
    end

    context 'when it succeeds' do
      let(:response) { double(:response, success?: false) }

      it 'returns false' do
        is_expected.to be_falsy
      end
    end
  end

  describe '#branches' do
    let(:service) { described_class.new(project) }

    before { allow(service).to receive(:api).and_return(response)}

    subject { service.branches }

    context 'when it fails' do
      let(:response) { double(:response, success?: false) }

      it { is_expected.to be_nil }
    end

    context 'when it succeeds' do
      let(:response) { double(:response, success?: true, data: [{ name: 'name', merged: true }]) }

      it 'returns projects' do
        is_expected.to contain_exactly(
          be_a(Gitlab::Branch) &
          have_attributes(name: 'name', merged: true)
        )
      end
    end
  end

  describe '#error_message' do
    let(:service) { described_class.new(project) }

    before { allow(service).to receive(:api).and_return(api) }

    subject { service.error_message }

    context 'when it has no response' do
      let(:api) { nil }

      it { is_expected.to be_nil }
    end

    context 'when it has a response' do
      let(:api) { double(:api, error_message: '401 Unauthorized') }

      it 'returns errors' do
        is_expected.to eq(api.error_message)
      end
    end
  end
end
