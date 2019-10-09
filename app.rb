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

get "/hijack" do
  if request.env['rack.hijack?']
    request.env['rack.hijack'].call
    io = request.env['rack.hijack_io']
    io.write(io.peeraddr.to_s)
    io.flush
    io.close
  end
    "no hijack"
end
