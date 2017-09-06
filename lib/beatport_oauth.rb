require "beatport_oauth/version"
require 'httparty'
require 'cgi'
require 'oauth'
require 'logger'
require 'json'

module BeatportOauth
  @request_token_path = "/identity/1/oauth/request-token"
  @authorize_path = "/identity/1/oauth/authorize"
  @authorize_submit_path = "/identity/1/oauth/authorize-submit"
  @access_token_path = "/identity/1/oauth/access-token"
  @site = "https://oauth-api.beatport.com"
  @callback = "https://oauth-api.beatport.com/callback"

  class << self
    attr_accessor :key, :secret, :username, :password, :access_token

    def get(uri, params = nil)
      check_vars
      JSON.parse(client.get(uri_helper(uri, params)).body)
    end

    def check_vars
      %w(key secret username password).each do |var|
        if send(var).nil?
          raise StandardError.new("No #{var} provided. " \
            "Set your #{var} using 'BeatportOauth.#{var} = <#{var}>'")
        end
      end
      check_access_token
    end

    def uri_helper(uri, params)
      uri = URI.parse(uri)
      uri.query = URI.encode_www_form(params) unless params.nil?
      uri.to_s
    end

    def check_access_token
      if access_token.nil?
        raise StandardError.new("No AccessToken found. " \
          "Create an AccessToken with BeatportOauth.get_access_token " \
          "and set it with 'BeatportOauth.access_token = <AccessToken>'" \
          "You may want to cache this AccessToken to save it across different requests.")
      end
    end

    def client
      @client ||= OAuth::AccessToken.new(
        consumer,
        access_token['oauth_token'],
        access_token['oauth_token_secret']
      )
    end

    def logger
      # logger.level = Logger::WARN
      @logger ||= Logger.new(STDOUT)
    end

    def consumer
      @consumer ||= OAuth::Consumer.new(@key, @secret,
                      site: @site,
                      request_token_path: @request_token_path,
                      authorize_path: @authorize_path,
                      access_token_path: @access_token_path)
    end

    def request_token
      # Step 1, get Request token
      @request_token ||= begin
        logger.info 'Getting request token from Beatport'
        consumer.get_request_token
      end
    end

    def authorize
      ## step 2, authorize to get oauth_verifier
      @authorize ||= begin
        logger.info 'Authorizing user for oauth_verifier'
        authorize_response = HTTParty.post(@site + @authorize_submit_path, body: authorize_options)
        CGI::parse(authorize_response.body)
      end
    end

    def authorize_options
      {
        oauth_token: request_token.token,
        username: @username,
        password: @password,
        submit: 'Login'
      }
    end

    def access_token_options
      {
        consumer: consumer,
        token: request_token,
        request_uri: access_token_url,
        oauth_verifier: authorize['oauth_verifier'][0]
      }
    end

    def access_token_url
      @access_token_url ||= URI.parse(@site + @access_token_path)
    end

    def get_access_token
      http = Net::HTTP.new(access_token_url.host, access_token_url.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(access_token_url.request_uri)
      oauth_helper = OAuth::Client::Helper.new request, access_token_options
      request["Authorization"] = oauth_helper.header
      logger.info 'Exchanging Request token for access token'

      ## step 3, get access token
      response = CGI::parse(http.request(request).body)
      {
        'oauth_token' => response['oauth_token'][0],
        'oauth_token_secret' => response['oauth_token_secret'][0]
      }
    end
  end
end
