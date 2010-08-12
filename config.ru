require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
require 'mongoshort'
run Sinatra::Application
