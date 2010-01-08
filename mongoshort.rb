require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'digest/md5'
require 'models/url'

# If using Basic Authentication, please change the default passwords!
CREDENTIALS = ['mongoshort', 'mongoshort']

configure :development do
  MongoMapper.database = 'urls_dev'
end

configure :test do
  MongoMapper.database = 'urls_test'
end

configure :production do
  # If using a separate database (like MongoHQ - http://www.mongohq.com/), specify the connection here.
  # MongoMapper.connection = Mongo::Connection.new('mongo.host.com', 27017)
  MongoMapper.database = 'urls'
  
  # Only necessary if your database needs authentication (strongly recommended in production).
  # MongoMapper.database.authenticate('username', 'password')
end

helpers do
  # Does a few checks for HTTP Basic Authentication.
  def protected!
    auth = Rack::Auth::Basic::Request.new(request.env)

    # Return a 401 error if there's no basic authentication in the request.
    unless auth.provided?
      response['WWW-Authenticate'] = %Q{Basic Realm="Mongoshort URL Shortener"}
      throw :halt, [401, 'Authorization Required']
    end
  
    # Non-basic authentications will be returned as a bad request (400 error).
    unless auth.basic?
      throw :halt, [400, 'Bad Request']
    end

    # The basic checks are okay - Check if the credentials match.
    if auth.provided? && CREDENTIALS == auth.credentials
      return true
    else
      throw :halt, [403, 'Forbidden']
    end
  end
end

get '/' do
  # You can set up an index page (under the /public directory).
  "MongoShort"
end

get '/:url' do
  url = URL.find_by_url_key(params[:url])
  if url.nil?
    raise Sinatra::NotFound
  else
    redirect url.full_url
  end
end

post '/new' do
  protected!
  content_type :json
  
  if !params[:url]
    status 400
    return { :error => "'url' parameter is missing" }.to_json
  end
  
  url = URL.find_or_create(params[:url])
  return url.to_json
end

not_found do
  # Change this URL to wherever you want to be redirected if a non-existing URL key or an invalid action is called.
  redirect "http://#{Sinatra::Application.host}/"
end
