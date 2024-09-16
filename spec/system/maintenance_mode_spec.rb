require 'rails_helper'

RSpec.describe 'Maintenance mode' do
  context 'when maintenance mode is enabled' do
    before do
      ENV['MAINTENANCE_MODE'] = 'true'
    end

    it 'shows the maintenance screen on all URLS' do
      visit closed_nsm_claims_path
      expect(page).to have_content 'Sorry, the service is unavailable'
    end
  end
end
