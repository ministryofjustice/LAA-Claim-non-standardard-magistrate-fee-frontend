require 'rails_helper'

RSpec.describe ClaimsController do
  context 'index' do
    it 'does not raise any errors' do
      expect { get :index }.not_to raise_error
    end
  end
end
