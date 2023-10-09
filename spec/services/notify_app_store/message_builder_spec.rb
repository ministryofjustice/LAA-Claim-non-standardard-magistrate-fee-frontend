require 'rails_helper'

RSpec.describe NotifyAppStore::MessageBuilder do
  subject { described_class.new(claim:) }

  let(:claim) { instance_double(Claim, risk: 'high', current_version_record: version, events: events) }
  let(:version) { instance_double(Version, datax  ) }
  let(:events) { claim.defendants.first }

  it 'will generate and send the data message for a claim' do
    travel_to(Time.zone.local(2023, 8, 17, 12, 13, 14)) do
      tester.process(subject.message)

      expect(tester).to have_received(:process).with(
        application: {
          'agent_instructed' => 'no',
          'answer_equality' => nil,
          'arrest_warrant_date' => nil,
          'assigned_counsel' => 'no',
          'claim_type' => nil,
          'cntp_date' => nil,
          'cntp_order' => nil,
          'concluded' => nil,
          'conclusion' => nil,
          'court' => 'A Court',
          'cracked_trial_date' => nil,
          'created_at' => '2023-08-17T12:13:14.000Z',
          'defence_statement' => nil,
          'defendants' => [{
            'full_name' => 'bobjim',
            'id' => defendant.id,
            'maat' => 'AA1',
            'main' => true,
            'position' => 1
          }],
          'disability' => nil,
          'disbursements' =>
          [{
            'apply_vat' => 'no',
            'details' => 'Details',
            'disbursement_date' => '2023-08-16',
            'disbursement_type' => { en: an_instance_of(String), value: disbursement.disbursement_type },
            'id' => disbursement.id,
            'miles' => '100.0',
            'other_type' => { en: nil, value: nil },
            'pricing' => pricing[disbursement.disbursement_type],
            'prior_authority' => nil,
            'total_cost_without_vat' => disbursement.total_cost_without_vat.to_s,
            'vat_amount' => nil,
            'vat_rate' => 0.2
          }],
          'ethnic_group' => nil,
          'firm_office' => {
            'account_number' => '123ABC',
            'address_line_1' => '2 Laywer Suite',
            'address_line_2' => nil,
            'name' => 'Firm A',
            'postcode' => 'CR0 1RE',
            'previous_id' => nil,
            'town' => 'Lawyer Town'
          },
          'first_hearing_date' => '2023-03-01',
          'gender' => nil,
          'has_disbursements' => nil,
          'hearing_outcome' => 'CP01',
          'id' => claim.id,
          'in_area' => 'yes',
          'is_other_info' => nil,
          'laa_reference' => nil,
          'letters_and_calls' => [
            { 'count' => 2, 'pricing' => 4.09, 'type' => { en: 'Letters', value: 'letters' }, 'uplift' => nil },
            { 'count' => 3, 'pricing' => 4.09, 'type' => { en: 'Calls', value: 'calls' }, 'uplift' => nil }
          ],
          'main_offence' => claim.main_offence,
          'main_offence_date' => '2023-08-16',
          'matter_type' => '1',
          'number_of_hearing' => 1,
          'number_of_witnesses' => nil,
          'office_code' => '1A123B',
          'other_info' => nil,
          'plea' => claim.plea,
          'preparation_time' => nil,
          'prosecution_evidence' => nil,
          'reason_for_claim_other_details' => nil,
          'reasons_for_claim' => ['enhanced_rates_claimed'],
          'remitted_to_magistrate' => 'no',
          'remitted_to_magistrate_date' => nil,
          'rep_order_date' => '2023-08-16',
          'representation_order_withdrawn_date' => nil,
          'send_by_post' => nil,
          'signatory_name' => nil,
          'solicitor' => {
            'contact_email' => nil,
            'contact_full_name' => nil,
            'full_name' => 'Richard Jenkins',
            'previous_id' => nil,
            'reference_number' => '111222'
          },
          'status' => 'draft',
          'submiter' => { 'description' => nil, 'email' => 'provider@example.com' },
          'supplemental_claim' => nil,
          'time_spent' => nil,
          'ufn' => '20150612/001',
          'unassigned_counsel' => 'no',
          'updated_at' => '2023-08-17T12:13:14.000Z',
          'work_after' => nil,
          'work_after_date' => nil,
          'work_before' => nil,
          'work_before_date' => nil,
          'work_items' =>
          [{
            'completed_on' => '2023-08-16',
            'fee_earner' => 'jimbob',
            'id' => work_item.id,
            'pricing' => pricing[work_item.work_type],
            'time_spent' => 100,
            'uplift' => nil,
            'work_type' => { en: an_instance_of(String), value: work_item.work_type },
          }],
          'youth_count' => 'no'
        },
        application_id: claim.id,
        application_state: 'submitted',
        application_risk: 'high',
        json_schema_version: 1
      )
    end
  end
end
