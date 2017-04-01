require 'rubygems'
require 'sinatra/base'
require 'json'
require_relative './idq-client'

class IdqExample < Sinatra::Base

  def initialize
    super()

    # initialize a new IdQClient instance
    @idq = IdQClient.new('YOUR_CLIENT_ID',
                         'YOUR_CLIENT_SECRET',
                         'http://127.0.0.1:8123/oauthcallback'
    )
  end

  configure do
    enable :sessions
  end

  helpers do
    def username
      session[:identity] ? session[:identity] : 'Not logged in'
    end
  end

  before '/secure/*' do
    unless session[:identity]
      session[:previous_url] = request.path
      @authurl = @idq.get_auth_url()
      @error = 'Sorry, you need to be logged in to visit ' + request.path
      halt erb(:login_form)
    end
  end

  get '/' do
    @authurl = @idq.get_auth_url()
    erb (:index)
  end

  get '/login/form' do
    @authurl = @idq.get_auth_url()
    erb :login_form
  end

  get '/oauthcallback' do
    # Read access code
    access_code = params[:code]

    # Exchange access code for access token
    token_response = @idq.get_access_token(access_code)
    token_json = JSON.parse(token_response)
    access_token = token_json["access_token"]

    # Exchange access token for user ID
    user_response = @idq.get_user(access_token)
    puts "DEBUG! User: #{user_response}"

    user_json = JSON.parse(user_response)
    user = user_json["username"]

    # Establish session with user ID
    session[:identity] = user

    # Send user back to the previous URL that required authorization
    where_user_came_from = session[:previous_url] || '/'
    redirect to where_user_came_from
  end

  get '/logout' do
    session.delete(:identity)
    erb "<div class='alert alert-message'>Logged out</div>"
  end

  get '/secure/place' do
    erb 'This is a secret place that only <%=session[:identity]%> has access to!'
  end
end
