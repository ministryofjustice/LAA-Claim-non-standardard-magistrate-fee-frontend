module PriorAuthority
  class ApplicationsController < PriorAuthority::BaseController
    def your
      applications = PriorAuthorityApplication.pending_and_assigned_to(current_user).map do |application|
        BaseViewModel.build(:application_summary, application)
      end

      @pagy, @applications = pagy_array(applications)
    end
  end
end