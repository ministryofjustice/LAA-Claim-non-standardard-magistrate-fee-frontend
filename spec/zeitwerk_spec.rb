require 'rails_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'Zeitwerk compliance' do
  it 'eager loads all files without errors' do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
# rubocop:enable RSpec/DescribeClass
