require 'rails_helper'

RSpec.describe NonStandardMagistratesPayment::SupportingEvidencesController do
  context 'show' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:claim_summary) { instance_double(V1::ClaimSummary) }
    let(:supporting_evidence) do
      [instance_double(V1::SupportingEvidence, :file_path => '#', :file_name => 'test', :download_url= => '')]
    end

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive(:build).with(:claim_summary, anything).and_return(claim_summary)
      allow(BaseViewModel).to receive(:build).with(:supporting_evidence, anything,
                                                   anything).and_return(supporting_evidence)
    end

    it 'find and builds the required object' do
      get :show, params: { claim_id: }

      expect(Claim).to have_received(:find).with(claim_id)
      expect(BaseViewModel).to have_received(:build).with(:supporting_evidence, claim, 'supporting_evidences')
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :show, params: { claim_id: }

      expect(controller).to have_received(:render).with(locals: { claim:, claim_summary: })
      expect(response).to be_successful
    end
  end
end
