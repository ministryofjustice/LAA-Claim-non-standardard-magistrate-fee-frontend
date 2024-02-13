require 'rails_helper'

RSpec.describe Nsm::ClaimDetailsController do
  context 'show' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:claim_summary) { instance_double(Nsm::V1::ClaimSummary) }
    let(:claim_details) { instance_double(ClaimDetails::Table) }

    before do
      allow(AppStoreService).to receive(:get).and_return(claim)
      allow(BaseViewModel).to receive(:build).and_return(claim_summary)
      allow(ClaimDetails::Table).to receive(:new).and_return(claim_details)
    end

    it 'find and builds the required object' do
      get :show, params: { claim_id: }

      expect(AppStoreService).to have_received(:get).with(claim_id)
      expect(BaseViewModel).to have_received(:build).with(:claim_summary, claim)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :show, params: { claim_id: }

      expect(controller).to have_received(:render).with(locals: { claim:, claim_summary:, claim_details: })
      expect(response).to be_successful
    end
  end
end
