class URL
  include MongoMapper::Document

  key :url_key, String, :required => true
  key :full_url, String, :required => true

  def self.find_or_create(new_url)
    url_key = Digest::MD5.hexdigest(new_url)[0..4]
    # Check if the key exists, so we don't have to create the URL again.
    url = self.find_by_url_key(url_key)
    if url.nil?
      url = URL.create(:url_key => url_key, :full_url => new_url)
    end

    return { :short_url => url.short_url, :full_url => url.full_url }
  end

  def short_url
    # Note that if running locally, 'Sinatra::Application.host' will return '0.0.0.0'.
    if Sinatra::Application.port == 80
      "http://#{Sinatra::Application.host}/#{self.url_key}"
    else
      "http://#{Sinatra::Application.host}:#{Sinatra::Application.port}/#{self.url_key}"
    end
  end
end