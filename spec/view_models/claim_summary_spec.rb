require 'rails_helper'

RSpec.describe ClaimSummary do
  describe '#build' do
    it 'builds the object from the hash of attributes' do
      summary = ClaimSummary.build('laa_reference' => 'LA111', 'defendants' => [])
      expect(summary).to have_attributes(
        laa_reference: 'LA111',
        defendants: []
      )
    end
  end

  describe 'main_defendant_name' do
    it 'returns the name attibute from the main defendant' do
      defendants = [
        { 'main' => false, 'name' => 'jimbob' },
        { 'main' => true, 'name' => 'bobjim' },
      ]
      summary = ClaimSummary.new('defendants' => defendants)
      expect(summary.main_defendant_name).to eq('bobjim')
    end

    context 'when no main defendant record - shouold not be possible' do
      it 'returns an empty string' do
        defendants = [
          { 'main' => false, 'name' => 'jimbob' },
        ]
        summary = ClaimSummary.new('defendants' => defendants)
        expect(summary.main_defendant_name).to eq('')
      end
    end
  end
end