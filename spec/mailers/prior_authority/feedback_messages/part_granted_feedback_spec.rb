# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::FeedbackMessages::PartGrantedFeedback do
  subject(:feedback) { described_class.new(application, 'Caseworker part granted coz...') }

  let(:application) do
    create(
      :prior_authority_application,
      data: build(
        :prior_authority_data,
        laa_reference: 'LAA-FHaMVK',
        ufn: '111111/111',
        provider: { 'email' => 'provider@example.com' },
        defendant: { 'last_name' => 'Abrahams', 'first_name' => 'Abe' },
      )
    )
  end

  let(:feedback_template) { '97c0245f-9fec-4ec1-98cc-c9d392a81254' }
  let(:recipient) { 'provider@example.com' }

  describe '#template' do
    it 'has correct template id' do
      expect(feedback.template).to eq(feedback_template)
    end
  end

  describe '#contents' do
    it 'has expected content' do
      expect(feedback.contents).to include(
        laa_case_reference: 'LAA-FHaMVK',
        ufn: '111111/111',
        defendant_name: 'Abe Abrahams',
        application_total: 'TODO',
        part_grant_total: 'TODO',
        caseworker_decision_explanation: 'Caseworker part granted coz...',
        date: DateTime.now.strftime('%d %B %Y'),
        feedback_url: 'tbc',
      )
    end
  end

  describe '#recipient' do
    it 'has correct recipient' do
      expect(feedback.recipient).to eq(recipient)
    end
  end
end
