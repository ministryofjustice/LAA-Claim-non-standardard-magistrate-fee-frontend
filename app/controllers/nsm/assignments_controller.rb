module Nsm
  class AssignmentsController < Nsm::BaseController
    before_action :set_claim, only: %i[new create]

    def new
      @form = AssignmentForm.new
    end

    def create
      @form = AssignmentForm.new(params.require(:nsm_assignment_form).permit(:comment))
      if @form.valid?
        process_assignment(@form.comment)
      else
        render :new
      end
    end

    private

    def process_assignment(comment)
      claim.with_lock do
        if claim.assignments.none?
          assign_claim(comment)

          redirect_to nsm_claim_claim_details_path(claim)
        else
          redirect_to nsm_claim_claim_details_path(claim), flash: { notice: t('.already_assigned') }
        end
      end
    end

    def assign_claim(comment)
      Claim.transaction do
        claim.assignments.create!(user: current_user)
        ::Event::Assignment.build(submission: claim, current_user: current_user, comment: comment)
      end
    end

    def set_claim
      claim
    end

    def claim
      @claim ||= Claim.find(params[:claim_id])
    end
  end
end
