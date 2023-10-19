module V1
  class CoreCostSummary < BaseViewModel
    include Shared::WorkItemSummary

    SKIPPED_TYPES = %w[travel waiting].freeze

    attribute :work_items
    attribute :letters_and_calls

    def table_fields
      data_by_type.map do |work_type, total_cost, total_time_spent|
        [
          work_type,
          NumberTo.pounds(total_cost),
          total_time_spent ? "#{total_time_spent}min" : '',
        ]
      end
    end

    def summed_fields
      total_cost = data_by_type.sum { |_, cost, _| cost }
      [
        NumberTo.pounds(total_cost),
        ''
      ]
    end

    private

    def data_by_type
      @data_by_type ||= work_item_data + letter_and_call_data
    end

    def skip_work_item?(work_item)
      SKIPPED_TYPES.include?(work_item.work_type.value)
    end

    def letter_and_call_data
      rows = LettersAndCallsSummary.build_self('letters_and_calls' => letters_and_calls).rows
      rows.filter_map do |letter_or_call|
        next if letter_or_call.provider_requested_count.zero?

        [
          letter_or_call.type.to_s,
          letter_or_call.caseworker_amount || letter_or_call.provider_requested_amount,
          nil
        ]
      end
    end
  end
end
