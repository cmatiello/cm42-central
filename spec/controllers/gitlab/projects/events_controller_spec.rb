require 'rails_helper'

describe Gitlab::Projects::EventsController, type: :controller do
  let!(:story) { FactoryBot.create(:story, :with_project, branch: 'test-branch') }
  let!(:project) { story.project }
  let!(:integration) do
    FactoryBot.create(
      :integration,
      project: project,
      kind: 'gitlab',
      data: {
        'secret_key' => 'secret_key'
      }
    )
  end
  let(:params) {
    {
      'object_attributes' => {
        'source_branch' => 'test-branch'
      }
    }
  }
  let(:headers) { { 'X-Gitlab-Token': token } }

  describe '#create' do
    before do
      allow(Gitlab::ProjectEventsService).to receive(:perform).and_return(true)
      allow(subject).to receive(:params).and_return(params)
    end

    context 'with an valid secret key' do
      let(:token) { 'secret_key' }
      it 'returns success' do
        request.headers.merge! headers
        post :create, xhr: true
        expect(response.status).to eq(200)
      end
    end

    context 'with an invalid secret key' do
      let(:token) { 'false' }
      it 'returns a failure' do
        request.headers.merge! headers
        post :create, xhr: true
        expect(response.status).to eq(422)
      end
    end
  end
end
