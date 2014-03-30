require 'sinatra/base'
require File.expand_path('../../../modules/querystringbuilder.rb', __FILE__)

RSpec.configure do |c|
  c.include Sinatra::QueryStringBuilder
end

describe "query builder" do
  it  "has acces to a method defined in the module" do
    expect(build_property_array("test")).to eq([],[])
  end

end
