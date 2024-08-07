namespace :update_to_app_store do
  desc 'Re-update events for a list of submissions by id'
  task :fix_events, [:ids] => [:environment] do |t, args|
    id_array = args[:ids].split(',')
    id_array.each do |submission_id| do
      working_submission = Submission.find(submission_id)
      if working_submission.present?
        autogrant_event = working_submission.events.find_by(event_type: 'auto_decision')
        print "Syncing events to app store for Submission: #{submission_id}"
        NotifyEventAppStore.perform_later(event: autogrant_event)
      end
    end
  end
end
