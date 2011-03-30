require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require(:default, :test)
require './mongoshort'
require 'test/unit'

set :environment, :test

class UrlTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    URL.create(:url_key => '83802', :full_url => 'http://www.amazon.com')
    URL.create(:url_key => '9b80a', :full_url => 'http://www.ebay.com')
    URL.create(:url_key => '612c1', :full_url => 'http://news.ycombinator.com')
  end

  def teardown
    URL.delete_all
  end
  
  def set_authorization!
    authorize 'mongoshort', 'mongoshort'
  end
  
  def test_key_should_redirect_to_full_url_if_url_key_exists
    get '/83802'
    assert last_response.redirect?
    follow_redirect!
    assert_equal "http://www.amazon.com/", last_request.url
    
    get '/9b80a'
    assert last_response.redirect?
    follow_redirect!
    assert_equal "http://www.ebay.com/", last_request.url
    
    get '/612c1'
    assert last_response.redirect?
    follow_redirect!
    assert_equal "http://news.ycombinator.com/", last_request.url
  end

  def test_full_url_redirect_should_be_301
    get '/612c1'
    assert_equal 301, last_response.status
  end
  
  def test_key_should_update_the_last_access_date
    Timecop.freeze do
      get '/83802'
      url = URL.find_by_url_key('83802')
      assert_equal Time.now, url.last_accessed
    end
  end
  
  def test_key_should_increment_times_viewed
    url = URL.find_by_url_key('83802')
    assert_equal url.times_viewed, 0
    get '/83802'
    url.reload
    assert_equal url.times_viewed, 1
  end
  
  def test_key_should_redirect_to_default_host_if_url_key_does_not_exist
    get '/abcde'
    assert last_response.redirect?
    follow_redirect!
    assert_equal "http://0.0.0.0/", last_request.url
  end
  
  def test_new_should_return_status_401_if_no_authentication_info_provided
    post '/new'
    assert_equal 401, last_response.status
  end
  
  def test_new_should_return_status_403_if_authentication_info_incorrect
    authorize  'mongoshort', 'incorrect-password'
    post '/new'
    assert_equal 403, last_response.status
  end
  
  def test_new_content_type_should_be_json
    set_authorization!
    post '/new'
    assert_equal "application/json", last_response.headers["Content-Type"]
  end
  
  def test_new_should_return_status_400_if_params_are_missing
    set_authorization!
    post '/new'
    assert_equal 400, last_response.status
  end
  
  def test_new_should_return_error_key_if_params_are_missing
    set_authorization!
    post '/new'
    response_hash = JSON.parse(last_response.body)
    assert response_hash.has_key?('error')
    assert "'url' parameter is missing", response_hash['error']
  end
  
  def test_new_should_use_a_five_character_hash
    set_authorization!
    post '/new', { :url => 'http://www.google.com' }
    new_url = URL.find_by_full_url('http://www.google.com')
    assert_equal 5, new_url.url_key.length
  end
  
  def test_new_should_create_a_new_record_if_url_does_not_exist
    set_authorization!
    url_count = URL.count
    post '/new', { :url => 'http://www.google.com' }
    assert_equal url_count + 1, URL.count
  end
  
  def test_new_should_not_create_a_new_record_if_url_already_exists
    set_authorization!
    url_count = URL.count
    post '/new', { :url => 'http://www.amazon.com' }
    assert_equal url_count, URL.count
  end
  
  def test_new_should_return_short_url_and_full_url
    set_authorization!
    post '/new', { :url => 'http://www.amazon.com' }
    new_url = URL.find_by_full_url('http://www.amazon.com')
    response_hash = JSON.parse(last_response.body)
    assert_equal new_url.short_url, response_hash["short_url"]
    assert_equal 'http://www.amazon.com', response_hash["full_url"]
  end
end
