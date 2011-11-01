require 'sinatra'
require './app'
require './lib/store'

set :environment, :development

Store.setup
run Sinatra::Application