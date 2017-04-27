require 'sinatra'

get '/' do
  "hello\n"
end

get "/env" do
  "#{ request.env }"
end
