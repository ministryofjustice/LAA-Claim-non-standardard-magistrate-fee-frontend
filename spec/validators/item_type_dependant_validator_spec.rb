require 'rails_helper'

RSpec.describe ItemTypeDependantValidator do
  subject(:instance) { klass.new(items:) }

  let(:klass) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      def self.model_name
        ActiveModel::Name.new(self, nil, 'temp')
      end

      attribute :items
      validates :items, item_type_dependant: true
    end
  end

  context 'when attribute is a positive number' do
    let(:items) { 1 }

    it 'form object is valid' do
      expect(instance).to be_valid
    end
  end

  context 'when attribute is nil' do
    let(:items) { nil }

    it 'adds blank error' do
      expect(instance).not_to be_valid
      expect(instance.errors.of_kind?(:items, :blank)).to be(true)
    end

    it 'adds item_type option to error object' do
      instance.validate
      expect(instance.errors.map(&:options)).to all(include(:item_type))
    end
  end

  context 'when attribute is a string' do
    let(:items) { 'one' }

    it 'adds not_a_number error' do
      expect(instance).not_to be_valid
      expect(instance.errors.of_kind?(:items, :not_a_number)).to be(true)
    end
  end

  context 'when attribute is zero' do
    let(:items) { 0 }

    it 'adds no greater_than error to items' do
      expect(instance).to be_valid
      expect(instance.errors.of_kind?(:items, :greater_than)).to be(false)
    end
  end

  context 'when model has an item_type attribute' do
    subject(:instance) { klass.new(items:, item_type:) }

    let(:klass) do
      Class.new do
        include ActiveModel::Model
        include ActiveModel::Attributes

        def self.model_name
          ActiveModel::Name.new(self, nil, 'temp')
        end

        attribute :item_type, :string

        attribute :items

        validates :items, item_type_dependant: true
      end
    end

    context 'when attribute is nil' do
      let(:items) { nil }
      let(:item_type) { 'word' }

      it 'include item type option from model' do
        instance.validate
        expect(instance.errors.details[:items].flat_map(&:values)).to include('words')
      end
    end
  end
end
