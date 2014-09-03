require 'sinatra'
require 'sinatra/reloader'
require 'oauth'
require 'json'

enable :sessions

CLIENT_KEY = 'C2OopumJauMV0itLFDH3mzaPK'
CLIENT_SECRET = 'yhIrXc8wOm4MJTw50IqOVfXexSqe7zS4YRONMyFtIUyMQSSA4E'

get "/" do
	erb :index
end

get "/get-request-token" do
	request_token = @oauth.get_request_token( :oauth_callback => 'http://127.0.0.1:4567/callback')
	session[:token] = request_token.token
	session[:secret] = request_token.secret
	redirect request_token.authorize_url
end

get "/callback" do
	request_token = OAuth::RequestToken.new( @oauth, session[:token], session[:secret])
	access_token = request_token.get_access_token( :oauth_verifier => params[:oauth_verifier] )
	session[:access_token] = access_token
	redirect "/tweets"
end

get '/tweets' do
	raw_data = @oauth.request(:get, "/1.1/statuses/home_timeline.json", session[:access_token], {:scheme => :query_string})
	puts raw_data.body.inspect
	@tweets = JSON.parse(raw_data.body)
	erb :tweets
end

before do
	@oauth = OAuth::Consumer.new( CLIENT_KEY, CLIENT_SECRET, { site: 'https://api.twitter.com'} )
end