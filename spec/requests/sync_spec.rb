require 'rails_helper'

RSpec.describe 'Syncs' do
  describe 'GET /sync' do
    it 'triggers a sync job' do
      get '/sync'

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /app_store_webhook' do
    let(:record) { { 'foo' => 'bar' } }

    context 'when no auth token is provided' do
      it 'rejects all requests' do
        post '/app_store_webhook'
        expect(response).to have_http_status :unauthorized
      end

      context 'when authentication can be bypassed' do
        let(:token_provider) { instance_double(AppStoreTokenProvider) }

        before do
          allow(AppStoreTokenProvider).to receive(:instance).and_return(token_provider)
          allow(token_provider).to receive(:authentication_configured?).and_return false
        end

        it 'triggers a sync' do
          post '/app_store_webhook', params: { submission_id: '123', data: record }, headers: { 'Authorization' => 'Bearer ABC' }
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when an auth token is provided' do
      before do
        AppStoreTokenAuthenticator.instance_variable_set(:@jwks, nil)
        stub_request(:get, 'https://login.microsoftonline.com/123/.well-known/openid-configuration')
          .to_return(status: 200,
                     body: { jwks_uri: 'https://example.com/jwks' }.to_json,
                     headers: { 'Content-type' => 'application/json' })
        stub_request(:get, 'https://example.com/jwks')
          .to_return(status: 200,
                     body: { keys: 'keys' }.to_json,
                     headers: { 'Content-type' => 'application/json' })
      end

      context 'when the token is invalid' do
        it 'rejects the request' do
          post '/app_store_webhook', headers: { 'Authorization' => 'Bearer ABC' }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when the token is valid' do
        let(:jwks) { instance_double(JWT::JWK::Set) }
        let(:decoded) do
          [{ 'aud' => 'UNDEFINED_APP_STORE_CLIENT_ID',
             'iss' => 'https://login.microsoftonline.com/123/v2.0',
             'exp' => 1.hour.from_now.to_i }]
        end

        before do
          allow(JWT::JWK::Set).to receive(:new).with('keys').and_return(jwks)
          allow(JWT).to receive(:decode).with('ABC', nil, true, { algorithms: 'RS256', jwks: jwks }).and_return(decoded)
        end

        it 'triggers a sync' do
          post '/app_store_webhook', params: { submission_id: '123', data: record }, headers: { 'Authorization' => 'Bearer ABC' }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
