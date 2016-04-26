ENV['RACK_ENV'] = 'test'

require './app.rb'
require 'sinatra'
require 'test/unit'
require 'rack/test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_says_hello
    get '/'
    assert last_response.ok?
    assert_equal "hello\n", last_response.body
  end

end
