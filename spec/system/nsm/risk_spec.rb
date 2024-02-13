require 'rails_helper'

RSpec.describe 'Risk' do
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim) }

  before do
    allow(AppStoreService).to receive_messages(list: [[claim], 1], get: claim, change_risk: nil)
    sign_in user
    claim
    visit '/'
    click_on claim.data['laa_reference']
    expect(page).to have_content 'Low risk'
    click_on 'Change risk'
  end

  it 'lets me change the risk' do
    choose 'Medium risk'
    fill_in 'Explain your decision', with: 'Looks shifty to me'
    click_on 'Change risk'
    expect(page).to have_content 'You changed the claim risk to medium'
  end

  it 'prevents me changing the risk without a reason' do
    choose 'Medium risk'
    click_on 'Change risk'
    expect(page).to have_content "There is a problem on this page\nExplain why you are changing the risk"
  end

  it 'lets me cancel' do
    click_on 'Cancel'
    expect(page).to have_current_path nsm_claim_claim_details_path(claim)
    expect(page).to have_content 'Low risk'
  end
end
