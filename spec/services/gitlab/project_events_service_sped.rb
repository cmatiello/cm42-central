require 'rails_helper'

describe Gitlab::ProjectEventsService do
  describe '#perform' do
    subject { service.perform }
    let(:service) { described_class.new(params) }

    before do
      allow(service).to receive(:story).and_return('story')
      allow(service).to receive(:user).and_return('user')
      allow(StoryOperations::Update).to receive(:call).with(
        'story',
        { state: 'delivered' },
        'user'
      ).and_return(true)
    end

    context 'when merged' do
      let(:params) { { 'object_attributes' => { 'action' => 'merge' }, 'object_kind' => 'merge_request' } }
      it { is_expected.to eq(true) }
    end

    context 'when not merged' do
      let(:params) { { 'object_attributes' => { 'action' => 'update' }, 'object_kind' => 'other' } }
      it { is_expected.to eq(nil) }
    end
  end
end
