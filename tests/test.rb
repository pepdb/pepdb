#require  File.expand_path 'test_helper.rb', __FILE__
require_relative 'test_helper.rb'


class MyTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end

  def test_hello_world
    get '/'
    assert last_response.ok?
    assert_equal last_response.body.must_include "pepDB"
  end
end
