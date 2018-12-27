require 'sinatra'

get '/' do
  "hello\n"
end

get '/sleep320' do
  sleep 320
  "hello\n"
end

get "/env" do
  "#{ request.env }"
end

get "/hostname" do
  "#{ ENV['HOSTNAME'] }"
end

get "/path/test" do
  "/path/test"
end
