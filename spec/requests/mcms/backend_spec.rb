require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe "/mcms/backend" do
  before(:each) do
    @response = request("/mcms/backend")
  end
end