class Event
  class Edit < Event
    def self.build(submission:, linked:, details:, current_user:)
      create(
        submission: submission,
        submission_version: submission.current_version,
        primary_user: current_user,
        linked_type: linked.fetch(:type),
        linked_id: linked.fetch(:id, nil),
        details: details,
      )
    end
  end
end
