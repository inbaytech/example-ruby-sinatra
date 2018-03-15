# idq-client.rb
# Copyright (c) 2016 inBay Technologies Inc.
# MIT Licensed

# Imports
require 'uri'
require 'querystring'
require 'rest-client'

##
# IdQClient implements a basic client for the idQ TaaS Backend API
# for explicit authentication flow.
class IdQClient
  # Class variables
  @@idq_host = 'taas.idquanta.com'
  @@idq_port = 443
  @@path_auth = '/idqoauth/api/v1/auth'
  @@path_token = '/idqoauth/api/v1/token'
  @@path_user = '/idqoauth/api/v1/user'

  ##
  # Constructor
  # ---
  # Parameters
  # +client_id+ :: client_id, as part of the OAuth 2.0 client credentials issued to this web app
  # +client_secret+ :: client_secret, as part of the OAuth 2.0 client credentials issued to this web app
  # +redirect_url+ :: the URL endpoint at which this web application listens for the idQ TaaS backend to
  # redirect the user agent back to, together with a one time authorization code.
  def initialize(client_id, client_secret, redirect_uri)
    # Instance variables
    @client_id = client_id
    @client_secret = client_secret
    @redirect_uri = redirect_uri
  end

  ##
  # Build an authentication URL link. Commonly used as an +href+ address for Login buttons.
  def get_auth_url()
    uri = URI::HTTPS.build(:host => @@idq_host,
                           :port => @@idq_port,
                           :path => @@path_auth,
                           :query => QueryString.stringify({:client_id => @client_id,
                                                            :state => 1234567,
                                                            :response_type => "code",
                                                            :scope => "optional",
                                                            :redirect_uri => @redirect_uri
                                                           }))
    uri
  end

  ##
  # Exchange a one-time authorization code for an OAuth 2.0 access token.
  # Calls the idQ TaaS backend Token Endpoint.
  # ---
  # Parameters
  # +access_code+ :: The one-time authorization code that the user was redirected with to the callback URL
  # ---
  # Returns
  # +response+ :: A JSON String
  def get_access_token(access_code)
    uri = "https://#{@@idq_host}:#{@@idq_port}#{@@path_token}"
    puts "DEBUG! Token URL: #{uri}"
    begin
      response = RestClient.post(uri, {client_id: @client_id,
                                       client_secret: @client_secret,
                                       code: access_code,
                                       redirect_uri: @redirect_uri,
                                       grant_type: 'authorization_code'
                                      }
                                )
    rescue RestClient::BadRequest => err
      puts "DEBUG! Bad Request: #{err.response}"
    end
    # Response is commonly a JSON string
    response
  end

  ##
  # Exchange an +access_token+ for a user information object
  # ---
  # Parameters
  # +access_token+ :: An OAuth 2.0 access token that can be used a single time in exchange for user info
  # ---
  # Returns
  # +response+ :: A JSON String
  def get_user(access_token)
    uri = "https://#{@@idq_host}:#{@@idq_port}#{@@path_user}"
    response = RestClient.get(uri, {:params => {:access_token => access_token}})
    response
  end
end
