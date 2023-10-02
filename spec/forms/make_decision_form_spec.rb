require 'rails_helper'

RSpec.describe MakeDecisionForm do
  subject { described_class.new(params) }
  let(:claim) { create(:claim) }

  describe '#validations' do
    context 'when state is not set' do
      let(:params) { {} }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:state, :inclusion)).to be(true)
      end
    end

    context 'when state is invalid' do
      let(:params) { { id: claim.id, state: 'other' } }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:state, :inclusion)).to be(true)
      end
    end

    context 'when state is grant' do
      let(:params) { { id: claim.id, state: 'grant' } }

      it { expect(subject).to be_valid }
    end

    context 'when state is part_grant' do
      context 'when partial_comment is blank' do
        let(:params) { { id: claim.id, state: 'part_grant', partial_comment: nil } }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:partial_comment, :blank)).to be(true)
        end
      end

      context 'when partial_comment is set' do
        let(:params) { { id: claim.id, state: 'part_grant', partial_comment: 'part grant comment' } }

        it { expect(subject).to be_valid }
      end
    end

    context 'when state is reject' do
      context 'when reject_comment is blank' do
        let(:params) { { id: claim.id, state: 'reject', reject_comment: nil } }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:reject_comment, :blank)).to be(true)
        end
      end

      context 'when reject_comment is set' do
        let(:params) { { id: claim.id, state: 'reject', reject_comment: 'reject comment' } }

        it { expect(subject).to be_valid }
      end
    end
  end

  describe '#persistance' do
    let(:user) { instance_double(User) }
    let(:claim) { create(:claim) }
    let(:params) { { id: claim.id, state: 'part_grant', partial_comment: 'part comment', current_user: user } }

    before do
      allow(Event::Decision).to receive(:build)
      allow(NotifyAppStore).to receive(:process)
    end

    it 'updates the claim' do
      subject.save
      expect(claim.reload).to have_attributes(state: 'part_grant')
    end

    it 'creates a Decision event' do
      subject.save
      expect(Event::Decision).to have_received(:build).with(
        claim: claim, comment: 'part comment', previous_state: 'submitted', current_user: user
      )
    end

    it 'trigger an update to the app store' do
      subject.save
      expect(NotifyAppStore).to have_received(:process).with(claim)
    end

    it { expect(subject.save).to be_truthy }

    context 'when not valid' do
      let(:params) { {} }

      it { expect(subject.save).to be_falsey }
    end

    context 'when error during save' do
      before do
        allow(Claim).to receive(:find_by).and_return(claim)
        allow(claim).to receive(:update!).and_raise(StandardError)
      end

      it { expect(subject.save).to be_falsey }
    end

    context 'when error during event creation' do
      before do
        allow(Event::Decision).to receive(:build).and_raise(StandardError)
      end

      it { expect(subject.save).to be_falsey }

      it 'does not update the claim' do
        subject.save
        expect(claim.reload).to have_attributes(state: 'submitted')
      end
    end
  end

  describe '#comment' do
    let(:params) { { state: state, partial_comment: 'part comment', reject_comment: 'reject comment' } }

    context 'when state is grant' do
      let(:state) { 'grant' }

      it 'ignores all comment fields' do
        expect(subject.comment).to be_nil
      end
    end

    context 'when state is grant' do
      let(:state) { 'part_grant' }

      it 'uses the partial_comment field' do
        expect(subject.comment).to eq('part comment')
      end
    end

    context 'when state is reject' do
      let(:state) { 'reject' }

      it 'uses the reject_comment field' do
        expect(subject.comment).to eq('reject comment')
      end
    end
  end
end