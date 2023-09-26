require 'rails_helper'

RSpec.describe Event::NewVersion do
  subject { described_class.build(claim:) }

  let(:claim) { create(:claim) }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      claim_id: claim.id,
      claim_version: 1,
      event_type: 'Event::NewVersion',
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('New claim versions received')
  end
end
