module Nsm
  class AdditionalFeesController < Nsm::BaseController
    before_action :fail_if_no_additional_fees

    layout nil

    include Nsm::AdjustmentConcern

    FORMS = {
      'youth_court_fee' => AdditionalFeesForm::YouthCourtFee
    }.freeze

    def index
      authorize(claim, :show?)
      records = BaseViewModel.build(:additional_fees_summary, claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, claim)
      summary = nil
      scope = :additional_fees
      pagy = nil
      type_changed_records = BaseViewModel.build(:work_item, claim, 'work_items').filter do |work_item|
        work_item.work_type != work_item.original_work_type
      end

      render 'nsm/review_and_adjusts/show',
             locals: { claim:, records:, summary:, claim_summary:, core_cost_summary:, pagy:, scope:, type_changed_records: }
    end

    def show
      authorize(claim, :show?)
      rows = BaseViewModel.build(:additional_fees_summary, claim).rows
      item = rows.detect do |model|
        model.type == params[:id].to_sym
      end

      render locals: { claim:, item:, }
    end

    def edit
      authorize(claim, :edit?)
      rows = BaseViewModel.build(:additional_fees_summary, claim).rows
      item = rows.detect do |model|
        model.type == params[:id].to_sym
      end

      render locals: { claim:, item:, }
    end

    def adjusted
      authorize(claim, :show?)
      records = BaseViewModel.build(:additional_fees_summary, claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, claim)
      scope = :additional_fees
      pagy = nil

      render 'nsm/adjustments/show', locals: { claim:, records:, claim_summary:, core_cost_summary:, pagy:, scope: }
    end

    private

    def claim
      @claim ||= Claim.load_from_app_store(params[:claim_id])
    end

    # :nocov:
    # Remove these when this is implemented
    def form_class
      FORMS[params[:id]]
    end
    # :nocov:

    def fail_if_no_additional_fees
      raise ActionController::RoutingError, 'Not Found' unless claim.additional_fees?
    end
  end
end