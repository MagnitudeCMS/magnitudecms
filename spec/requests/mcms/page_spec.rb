require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe "/mcms/page" do
  before(:each) do
    @response = request("/mcms/page")
  end
end