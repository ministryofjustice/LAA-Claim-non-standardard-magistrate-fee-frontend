class NotifyAppStore < ApplicationJob
  queue_as :default

  def self.process(claim:, email_content:, comment:)
    if ENV.key?('REDIS_HOST')
      set(wait: Rails.application.config.x.application.app_store_wait.seconds).perform_later(claim, email_content)
    else
      begin
        new.notify(MessageBuilder.new(claim:))
        ClaimFeedbackMailer.notify(email_content.new(claim, comment))
      rescue StandardError => e
        # we only get errors here when processing inline, which we don't want
        # to be visible to the end user, so swallow errors
        Sentry.capture_exception(e)
      end
    end
  end

  def perform(claim, email_content, comment)
    notify(MessageBuilder.new(claim:))
    ClaimFeedbackMailer.notify(email_content.new(claim, comment))
  end

  def notify(message_builder)
    raise 'SNS notification is not yet enabled' if ENV.key?('SNS_URL')

    # implement and call SNS notification

    # TODO: we only do post requests here as the system is not currently
    # able to support re-sending/submitting an appplication so we can ignore
    # put requests
    post_manager = HttpNotifier.new
    post_manager.put(message_builder.message)
  end
end
