module PriorAuthority
  class AdditionalCostForm < BaseAdjustmentForm
    LINKED_CLASS = V1::AdditionalCost

    PER_ITEM = 'per_item'.freeze
    PER_HOUR = 'per_hour'.freeze

    attribute :id, :string
    attribute :unit_type, :string
    attribute :items, :integer
    attribute :cost_per_item, :gbp
    attribute :period, :time_period
    attribute :cost_per_hour, :gbp

    with_options if: :per_item? do
      validates :items, presence: true, numericality: { greater_than: 0 }, is_a_number: true
      validates :cost_per_item, presence: true, numericality: { greater_than: 0 }, is_a_number: true
    end

    with_options if: :per_hour? do
      validates :period, presence: true, time_period: true
      validates :cost_per_hour, presence: true, numericality: { greater_than: 0 }, is_a_number: true
    end

    def save
      return false unless valid?

      PriorAuthorityApplication.transaction do
        process_field(value: period.to_i, field: 'period')

        submission.save
      end

      true
    end

    private

    def per_item?
      unit_type == PER_ITEM
    end

    def per_hour?
      unit_type == PER_HOUR
    end

    def selected_record
      @selected_record ||= submission.data['additional_costs'].detect do |row|
        row.fetch('id') == item.id
      end
    end

    def data_has_changed?
      period != item.period || cost_per_hour != item.cost_per_hour
    end
  end
end
