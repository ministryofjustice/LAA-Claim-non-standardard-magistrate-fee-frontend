require 'rails_helper'

RSpec.describe V1::ContactDetails do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Contact details')
    end
  end

  # rubocop:disable RSpec/ExampleLength
  describe '#rows' do
    it 'has correct structure' do
      subject = described_class.new(
        {
          'firm_office' => {
            'name' => 'Blundon Solicitor Firm',
            'town' => 'Stoke Newington',
            'postcode' => 'NE10 4AB',
            'account_number' => '121234',
            'address_line_1' => '1 Princess Road',
            'address_line_2' => nil
          },
          'solicitor' => {
            'full_name' => 'Daniel Treaty',
            'reference_number' => '1212333',
          }
        }
      )

      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end
  # rubocop:enable RSpec/ExampleLength

  describe '#data' do
    context 'One line in firm address' do
      subject = described_class.new(
        {
          'firm_office' => {
            'name' => 'Blundon Solicitor Firm',
            'town' => 'Stoke Newington',
            'postcode' => 'NE10 4AB',
            'account_number' => '121234',
            'address_line_1' => '1 Princess Road',
            'address_line_2' => nil
          },
          'solicitor' => {
            'full_name' => 'Daniel Treaty',
            'reference_number' => '1212333',
          }
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            { title: 'Firm name', value: 'Blundon Solicitor Firm' },
            { title: 'Firm account number', value: '121234' },
            { title: 'Firm address', value: '1 Princess Road<br>Stoke Newington<br>NE10 4AB' },
            { title: 'Solicitor full name', value: 'Daniel Treaty' },
            { title: 'Solicitor reference number', value: '1212333' }
          ]
        )
      end
    end

    context 'Two lines in firm address' do
      subject = described_class.new(
        {
          'firm_office' => {
            'name' => 'Blundon Solicitor Firm',
            'town' => 'Stoke Newington',
            'postcode' => 'NE10 4AB',
            'account_number' => '121234',
            'address_line_1' => 'Suite 3',
            'address_line_2' => '5 Princess Road'
          },
          'solicitor' => {
            'full_name' => 'Daniel Treaty',
            'reference_number' => '1212333',
          }
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            { title: 'Firm name', value: 'Blundon Solicitor Firm' },
            { title: 'Firm account number', value: '121234' },
            { title: 'Firm address', value: 'Suite 3<br>5 Princess Road<br>Stoke Newington<br>NE10 4AB' },
            { title: 'Solicitor full name', value: 'Daniel Treaty' },
            { title: 'Solicitor reference number', value: '1212333' }
          ]
        )
      end
    end
  end
end
