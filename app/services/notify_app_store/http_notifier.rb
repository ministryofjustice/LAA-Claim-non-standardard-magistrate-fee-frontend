class NotifyAppStore
  class HttpNotifier
    include HTTParty
    headers 'Content-Type' => 'application/json'

    def put(message)
      response = self.class.put("#{host}/v1/application/#{message[:application_id]}", **options(message))

      case response.code
      when 201
        :success
      when 409
        # can be ignored but should be notified so we can track when it occurs
        Sentry.capture_message("Application ID already exists in AppStore for '#{message[:application_id]}'")
        :warning
      else
        raise "Unexpected response from AppStore - status #{response.code} for '#{message[:application_id]}'"
      end
    end

    private

    def options(message)
      options = { body: message.to_json }

      token = AppStoreTokenProvider.instance.bearer_token

      options.merge(
        headers: {
          authorization: "Bearer #{token}"
        }
      )
    end

    def host
      ENV.fetch('APP_STORE_URL', 'http://localhost:8000')
    end
  end
end
