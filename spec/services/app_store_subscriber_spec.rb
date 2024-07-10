require 'rails_helper'

RSpec.describe AppStoreSubscriber do
  describe '.call' do
    let(:client) { instance_double(AppStoreClient) }

    before do
      allow(AppStoreClient).to receive(:new).and_return(client)
      allow(client).to receive(:create_subscription)
    end

    context 'when there is no defined host' do
      it 'does not make a request' do
        expect(AppStoreClient).not_to receive(:new)
        described_class.call
      end
    end

    context 'when there is a host' do
      around do |example|
        ENV['HOSTS'] = 'example.com'
        example.run
        ENV['HOSTS'] = nil
      end

      it 'makes a request' do
        described_class.call
        expect(client).to have_received(:create_subscription).with(
          webhook_url: 'http://example.com/app_store_webhook', subscriber_type: :caseworker
        )
      end

      context 'when the app store request errors out' do
        before do
          allow(client).to receive(:create_subscription).and_raise(StandardError)
          allow(Sentry).to receive(:capture_exception)
        end

        it 'passes the error to Sentry' do
          expect { described_class.call }.not_to raise_error
          expect(Sentry).to have_received(:capture_exception)
        end
      end
    end

    context 'when there are multiple hosts' do
      around do |example|
        ENV['HOSTS'] = 'other.com,example.com'
        example.run
        ENV['HOSTS'] = nil
      end

      it 'picks the first one' do
        described_class.call
        expect(client).to have_received(:create_subscription).with(
          webhook_url: 'http://other.com/app_store_webhook', subscriber_type: :caseworker
        )
      end
    end

    context 'when there is an internal host' do
      around do |example|
        ENV['INTERNAL_HOST_NAME'] = 'internal.svc.local'
        example.run
        ENV['INTERNAL_HOST_NAME'] = nil
      end

      it 'uses that' do
        described_class.call
        expect(client).to have_received(:create_subscription).with(
          webhook_url: 'http://internal.svc.local/app_store_webhook', subscriber_type: :caseworker
        )
      end
    end
  end
end
