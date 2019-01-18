require 'rails_helper'

describe Gitlab::Projects::EventsController, type: :controller do
  describe '#create' do
    before do
      allow(Gitlab::ProjectEventsService).to receive(:perform).and_return(true)
      allow(subject).to receive(:valid_secret_key?).and_return(result)
    end

    context 'with an valid secret key' do
      let(:result) { true }
      it 'returns success' do
        post :create, xhr: true
        expect(response.status).to eq(200)
      end
    end

    context 'with an invalid secret key' do
      let(:result) { false }
      it 'returns a failure' do
        post :create, xhr: true
        expect(response.status).to eq(422)
      end
    end
  end
end
