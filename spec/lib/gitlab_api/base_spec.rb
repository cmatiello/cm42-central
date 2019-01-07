require 'rails_helper'

describe GitlabApi::Base do
  describe '#connection' do
    let(:gitlab_api_url) { 'https://gitlab.com/api/v4' }
    let(:gitlab_private_token) { 'asdfasdf' }

    before do
      allow(api).to receive(:gitlab_api_url).and_return(gitlab_api_url)
      allow(api).to receive(:gitlab_private_token).and_return(gitlab_private_token)
    end

    let(:api) { described_class.new }
    subject { api.connection }

    it { is_expected.to be_a(Faraday::Connection) }

    it 'creates a connection with proper params' do
      is_expected.to have_attributes(
        headers: hash_including(
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Private-Token' => gitlab_private_token
        ),
        url_prefix: be_a(URI::HTTPS) & have_attributes(to_s: gitlab_api_url)
      )
    end
  end

  describe '#get' do
    let(:api) { described_class.new }
    let(:connection) { double :connection }
    let(:path) { 'projects' }
    let(:response) { 'response' }

    subject(:get_request) { api.get(path) }

    before do
      allow(api).to receive(:connection).and_return(connection)
      allow(connection).to receive(:get).with(path).and_return(response)
    end

    it 'sets the response' do
      get_request
      expect(api.response).to eq(response)
    end

    it 'returns self' do
      is_expected.to eq(api)
    end
  end

  describe '#data' do
    let(:data) { { 'name' => 'asdf', 'id' => 1 } }
    let(:response) { double(:response, body: data.to_json) }
    let(:api) { described_class.new }

    before do
      allow(api).to receive(:response).and_return(response)
    end

    subject { api.data }

    it { is_expected.to eq(data) }
  end

  describe '#success?' do
    before do
      stub_const("#{subject.class}::SUCCESS_RESPONSE_CODE", 200)
      allow(subject).to receive(:response).and_return(response)
    end

    context 'when it succeeds' do
      let(:response) { double(:response, status: 200) }
      it { is_expected.to be_success }
    end

    context 'when it fails' do
      let(:response) { double(:response, status: 401) }
      it { is_expected.not_to be_success }
    end
  end

  describe '#error_message' do
    let(:api) { described_class.new }
    subject { api.error_message }

    before do
      allow(api).to receive(:data).and_return(data)
      allow(api).to receive(:success?).and_return(response)
    end

    context 'when it failed' do
      let(:response) { false }

      context 'when it returns message' do
        let(:data) { { 'message' => '401 Unauthorized' } }

        it { is_expected.to eq(data['message']) }
      end

      context 'when it returns error' do
        let(:data) { { 'error' => '404 Not Found' } }

        it { is_expected.to eq(data['error']) }
      end
    end

    context 'when it succeeded' do
      let(:response) { true }
      let(:data) { { 'message' => 'it succeeded' } }

      it { is_expected.to be_nil }
    end

  end
end
