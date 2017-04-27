require 'sinatra'

get '/' do
  "hello\n"
end

get "/env" do
  puts "#{ request.env }"
end
