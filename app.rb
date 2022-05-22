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

get "/cookies" do
  "#{ request.cookies }"
end

get "/hostname" do
  "#{ ENV['HOSTNAME'] }"
end

get "/path/test" do
  "/path/test"
end

get "/metrics" do
  "hello_sinatra_random #{rand(0..100)}"
end

a = []

get "/oom" do
  loop do
    a << "1234567890"
  end
end
