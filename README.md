MongoShort
==========

MongoShort is a simple URL shortening service written in Ruby, using Sinatra and MongoDB.

Why another URL shortener?
==========================

This was originally written to be used privately within an existing website, so there is no user interface and not much in terms of validation. If you need a user interface or something more complex to shorten URLs, search around on GitHub for one of the many URL shortening applications that exist.

Also, it can serve as a very simple introduction to both [Sinatra](http://www.sinatrarb.com/) and/or [MongoMapper](http://github.com/jnunemaker/mongomapper). I built this out of curiosity more than out of necessity, so I hope it can help someone grasp some of the basics of these wonderful tools.

How does it work?
=================

MongoShort can generate shortened URLs by sending a POST request with a URL as a parameter. That's really all that's needed. MongoShort will return the shortened URL and the full URL in JSON format, which your app can easily parse. Since this was to be used privately within an existing site, [Basic Authentication](http://en.wikipedia.org/wiki/Basic_access_authentication) is used, but that can be easily removed if you don't want or need additional authentication.

What do I need?
===============

Currently, I've only used MongoShort on Ruby 1.8.7. I haven't tested yet on Ruby 1.9, but will soon.

To run MongoShort, download and install [MongoDB](http://www.mongodb.org/) for your system. I've tested MongoShort on MongoDB 1.4.x and 1.6.x, so it should work properly for either version.

[Bundler](http://gembundler.com/) is now required to use MongoShort and setup all necessary RubyGems. I'm currently using the latest Release Candidate of Bundler (1.0.0.rc.5). To install the latest Release Candidate of Bundler, execute the following command:

    gem install bundler --pre

Once Bundler is installed, you can install the necessary RubyGems by executing the following command:

    bundle install

The following RubyGems gems are used:

 * [Sinatra](http://www.sinatrarb.com/)
 * [MongoMapper](http://github.com/jnunemaker/mongomapper)
 * [Rack::Test](http://github.com/brynary/rack-test)
 * [Timecop](http://github.com/jtrupiano/timecop)

MongoShort uses Ruby's [Test::Unit](http://ruby-doc.org/stdlib/libdoc/test/unit/rdoc/classes/Test/Unit.html). To run the tests, make sure MongoDB is running, and execute the following Rake task:

    rake test

If you want to test MongoShort on a publicly available site, I highly recommend using [Heroku](http://heroku.com/) and [MongoHQ](http://www.mongohq.com/) to get up and running quickly. Heroku currently has [experimental support For Bundler](http://docs.heroku.com/bundler), so you can use the included Gemfile. MongoHQ databases, I included the necessary code needed to connect to your MongoHQ account and authenticate your database for the production environment.

Finally, how do I get a shortened URL?
======================================

First, make sure you have MongoDB running. If your database needs authentication, make sure to set the environment variables `mongodb_user` and `mongodb_pass`. Once MongoDB is properly running on a local development machine, you can start the application directly, which will launch the application running on Thin, Mongrel or WEBrick (depending on what you have installed):

    rackup

You can also run MongoShort with [Phusion Passenger](http://www.modrails.com/), [Unicorn](http://unicorn.bogomips.org/), or any other web server that supports [Rack](http://rack.rubyforge.org/). A basic Rackup file (`config.ru`) is included with MongoShort to help with your installation. Read the server's documentation for more information on how to run Rack applications.

Once running, MongoShort only has two actions - One action to create a new shortened URL, and another to redirect the user to the full URL.

To generate a shortened URL, the `/new` action can be accessed via a POST request, along with a `url` parameter. If Basic Authentication is required, a username and password is also necessary. Here's an example using [cURL](http://curl.haxx.se/) when running MongoShort locally:

    $ curl -i http://localhost:9292/new -X POST -u mongoshort:mongoshort -d url="http://github.com/"
    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: 81
    Connection: keep-alive
    Server: thin 1.2.5 codename This Is Not A Web Server

    {"short_url":"http://0.0.0.0:9292/a3ca1","full_url":"http://github.com"}

You can then serve the value of the `short_url` key to use for redirection. The 'key' at the end of the URL is MongoShort's second action. Whenever the user visits the site where you're hosting MongoShort, it will look at the key, search for it in the MongoDB database, and redirect the user to the full URL if it exists.

Note that the `short_url` field that's returned uses '0.0.0.0' as its URL because it's Sinatra's default host when running locally. If using Rack to run MongoShort (for example, using Phusion Passenger), your server of choice should return the correct host and port information. Alternatively, you can explicitly set it by using Sinatra's `:host` variable. Read Sinatra's [Options and Configuration](http://www.sinatrarb.com/configuration.html) section for more information.

Any future plans?
=================

I'm sure that using this extensively will uncover bugs and will also make me want to add new features, so I'll be updating MongoShort whenever I can. Feel free to leave comments, bug reports, recommendations, or anything else.
