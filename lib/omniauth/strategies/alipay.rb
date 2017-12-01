require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Alipay < OmniAuth::Strategies::OAuth2
      class Error < ::OAuth2::Error
        attr_reader :response_json, :sub_code, :sub_msg

        def initialize(response_json)
          @response_json = response_json
          error_response = response_json['error_response']
          @code = error_response['code']
          @description = error_response['msg']
          @sub_code = error_response['sub_code']
          @sub_msg = error_response['sub_msg']
        end

        def error_message
          @response_json['error_response'].to_json
        end

        def message
          error_message
        end
      end

      option :name, 'alipay'

      args [:client_id, :app_private_key, :alipay_public_key]

      option :app_private_key, nil
      option :alipay_public_key, nil

      option :client_options, {
        authorize_url: 'https://openauth.alipay.com/oauth2/publicAppAuthorize.htm',
        token_url: 'https://openauth.alipay.com/oauth2/token',
        url: 'https://openapi.alipay.com/gateway.do'
      }

      uid { raw_info['user_id'] }

      info do
        {
          avatar: raw_info['avatar'],
          user_type_value: raw_info['user_type_value'],
          user_status: raw_info['user_type_value'],
          gender: raw_info['gender'],
          is_certified: raw_info['is_certified'],
          province: raw_info['province'],
          city: raw_info['city'],
          is_student_certified: raw_info['is_student_certified'],
          alipay_user_id: raw_info['alipay_user_id'],
          nickname: raw_info['nick_name']
        }
      end

      extra do
        {raw_info: raw_info}
      end

      def request_phase
        params = client.auth_code.authorize_params.merge(redirect_uri: callback_url).merge(authorize_params)
        params['app_id'] = params.delete('client_id')
        params['scope'] = 'auth_user'
        params['state'] = 'init'
        params.delete('response_type')
        redirect client.authorize_url(params)
      end

      def raw_info
        return @raw_info if @raw_info
        alipay_client = ::Alipay::Client.new(
          url: options.client_options.url,
          app_id: options.client_id,
          app_private_key: options.app_private_key,
          alipay_public_key: options.alipay_public_key,
          sign_type: 'RSA'
        )
        params = alipay_client.sdk_execute(
          method: 'alipay.user.info.share',
          auth_token: access_token.token
        )
        response = client.request(:get, options.client_options.url, params: Rack::Utils.parse_nested_query(params))
        data = build_response_json(response.body)
        @raw_info = data['alipay_user_info_share_response']
      end

      protected

      def build_access_token
        alipay_client = ::Alipay::Client.new(
          url: options.client_options.url,
          app_id: options.client_id,
          app_private_key: options.app_private_key,
          alipay_public_key: options.alipay_public_key,
          sign_type: 'RSA'
        )
        params = alipay_client.sdk_execute(
          method: 'alipay.system.oauth.token',
          grant_type: 'authorization_code',
          code: request.params['auth_code']
        )
        response = client.request(:get, options.client_options.url, params: Rack::Utils.parse_nested_query(params))
        data = build_response_json(response.body)
        ::OAuth2::AccessToken.from_hash(client, data['alipay_system_oauth_token_response'].merge(deep_symbolize(options.auth_token_params)))
      end

      private

      # @param response_body [String] The response body
      # @return [Hash] A hash of the parsed body
      def build_response_json(response_body)
        data = JSON.parse(response_body)
        raise 'Cannot parse response body' unless data.is_a?(Hash)
        raise Error.new(data) if data.has_key?('error_response')
        data
      end
    end
  end
end
