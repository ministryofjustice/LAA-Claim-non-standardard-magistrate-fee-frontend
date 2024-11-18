require 'rails_helper'

RSpec.describe Nsm::Uplift::BaseForm do
  subject { implementation_class.new(claim:, current_user:, explanation:) }

  let(:implementation_class) { Nsm::Uplift::LettersAndCallsForm }
  let(:claim) { build(:claim) }
  let(:current_user) { instance_double(User) }
  let(:explanation) { 'some reason' }
  let(:app_store_client) { instance_double(AppStoreClient, adjust: true) }

  before { allow(AppStoreClient).to receive(:new).and_return(app_store_client) }

  describe '#validations' do
    it { expect(subject).to be_valid }

    context 'when explanation is not set' do
      let(:explanation) { nil }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:explanation, :blank)).to be(true)
      end
    end

    context 'when claim is not set' do
      let(:claim) { nil }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:claim, :blank)).to be(true)
      end
    end
  end

  describe '#save!' do
    let(:remover) { instance_double(implementation_class::Remover, valid?: valid, save: save) }
    let(:valid) { true }
    let(:save) { true }

    before do
      allow(implementation_class::Remover).to receive(:new).and_return(remover)
    end

    it 'creates a remover instance for each row of data' do
      subject.save!

      expect(implementation_class::Remover).to have_received(:new).twice
      claim.data['letters_and_calls'].each do |selected_record|
        expect(implementation_class::Remover).to have_received(:new)
          .with(
            claim:, explanation:, current_user:, selected_record:
          )
      end
    end

    context 'when the record has already been adjusted' do
      before do
        claim.data['letters_and_calls'][0]['adjustment_comment'] = 'Previous comment'
      end

      it 'preserves the previous comment' do
        subject.save!
        expect(implementation_class::Remover).to have_received(:new)
          .with(
            claim: claim,
            explanation: "Previous comment\n\n#{explanation}",
            current_user: current_user,
            selected_record: claim.data['letters_and_calls'][0]
          )
      end
    end

    context 'when invalid' do
      let(:explanation) { nil }

      it { expect(subject.save!).to be_falsey }

      it 'does not save' do
        expect(implementation_class::Remover).not_to have_received(:new)
      end
    end

    context 'when it raises and error' do
      before do
        allow(claim.data).to receive(:[]).and_raise(StandardError)
      end

      it { expect(subject.save!).to be_falsey }
    end

    context 'when the remove is not valid' do
      let(:valid) { false }

      it 'does not calls save' do
        subject.save!

        expect(remover).not_to have_received(:save)
      end
    end

    context 'when the remove is valid' do
      it 'calls save' do
        subject.save!

        expect(remover).to have_received(:save).twice
      end
    end
  end
end
