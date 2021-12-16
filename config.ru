#\ -p 8080
require './app'
set :bind, "::"
run Sinatra::Application
