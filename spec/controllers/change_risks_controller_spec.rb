require 'rails_helper'

RSpec.describe ChangeRisksController, type: :controller do
  context 'edit' do
    let(:claim) { instance_double(Claim, id: claim_id, risk: 'high') }
    let(:claim_id) { SecureRandom.uuid }
    let(:risk) { instance_double(ChangeRiskForm) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(ChangeRiskForm).to receive(:new).and_return(risk)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :edit, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim:, risk: })
      expect(response).to be_successful
    end
  end

  context 'update' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:risk) { instance_double(ChangeRiskForm, save:, risk_level:) }
    let(:user) { instance_double(User) }
    let(:risk_level) { 'high' }
    let(:save) { true }

    before do
      allow(User).to receive(:first_or_create).and_return(user)
      allow(ChangeRiskForm).to receive(:new).and_return(risk)
      allow(Claim).to receive(:find).and_return(claim)
    end

    it 'builds a risk object' do
      put :update, params: {
        claim_id: claim.id,
        change_risk_form: { risk_level: 'low', explanation: nil, id: claim.id }
      }
      # expect(risk).to have_received(:risk_level)
      expect(ChangeRiskForm).to have_received(:new).with(
        'risk_level' => 'low', 'explanation' => '', 'id' => claim.id, 'current_user' => user
      )
    end

    context 'when decision has an erorr being updated' do
      let(:save) { false }

      it 're-renders the edit page' do
        allow(controller).to receive(:render)
        put :update, params: {
          claim_id: claim.id,
        change_risk_form: { risk_level: 'low', explanation: nil, id: claim.id }
        }

        expect(controller).to have_received(:render)
                          .with(:edit, locals: { claim:, risk: })
      end
    end
  end
end
