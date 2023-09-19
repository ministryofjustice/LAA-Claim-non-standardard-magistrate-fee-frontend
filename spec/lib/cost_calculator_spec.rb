require 'rails_helper'

RSpec.describe CostCalculator do
  subject { described_class.cost(type, object) }

  context 'when type is work_item' do
    let(:type) { :work_item }

    context 'when uplift is present' do
      let(:object) { V1::WorkItem.new('time_spent' => 90, 'pricing' => 24.4, 'uplift' => 25) }

      it 'calculates the time * price * uplift' do
        expect(subject).to eq(45.75) # (90 / 60) * 24.4 * (125 / 100)
      end
    end

    context 'when uplift is not set' do
      let(:object) { V1::WorkItem.new('time_spent' => 90, 'pricing' => 24.4, 'uplift' => nil) }

      it 'calculates the time * price' do
        expect(subject).to eq(36.6) # (90 / 60) * 24.4
      end
    end
  end

  # placeholder for 100% coverage
  context 'when type is disbursement' do
    let(:type) { :disbursement }
    let(:object) { nil }

    it { expect(subject).to be_nil }
  end
end
