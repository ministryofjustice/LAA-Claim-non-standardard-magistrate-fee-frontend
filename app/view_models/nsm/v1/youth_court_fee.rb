module Nsm
  module V1
    class YouthCourtFee < AdditionalFee
      adjustable_attribute :include_youth_court_fee, :boolean
      attribute :youth_court_fee_adjustment_comment, :string

      def key
        'summary_table'
      end

      def title
        I18n.t(".nsm.youth_court_fee_adjustments.#{key}.title")
      end

      def data
        [
          {
            title: I18n.t(".nsm.youth_court_fee_adjustments.#{key}.additional_fee"),
            value: I18n.t(".nsm.youth_court_fee_adjustments.#{key}.youth_court_fee")
          },
          {
            title: I18n.t(".nsm.youth_court_fee_adjustments.#{key}.net_cost_claimed"),
            value: NumberTo.pounds(claimed_total_exc_vat)
          }
        ].compact
      end

      def rows
        { title:, data: }
      end

      def any_adjustments?
        include_ycf = submission.data['include_youth_court_fee']
        include_ycf_original = submission.data['include_youth_court_fee_original']

        return false if include_ycf.nil? || include_ycf_original.nil?

        include_ycf != include_ycf_original
      end
      alias changed? any_adjustments?

      def form_attributes
        remove_bool = ActiveModel::Type::Boolean.new.cast(include_youth_court_fee)
        remove_youth_court_fee = include_youth_court_fee_original.nil? ? nil : !remove_bool

        {
          'remove_youth_court_fee' => remove_youth_court_fee,
          'explanation' => youth_court_fee_adjustment_comment
        }
      end

      def type
        :youth_court_fee
      end
    end
  end
end
