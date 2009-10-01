require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

given "a layout exists" do
  request(resource(:layouts), :method => "POST", 
    :params => { :layout => { :id => nil }})
end

describe "resource(:layouts)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:layouts))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of layouts" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a layout exists" do
    before(:each) do
      @response = request(resource(:layouts))
    end
    
    it "has a list of layouts" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      @response = request(resource(:layouts), :method => "POST", 
        :params => { :layout => { :id => nil }})
    end
    
    it "redirects to resource(:layouts)" do
    end
    
  end
end

describe "resource(@layout)" do 
  describe "a successful DELETE", :given => "a layout exists" do
     before(:each) do
       @response = request(resource(Layout.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:layouts))
     end

   end
end

describe "resource(:layouts, :new)" do
  before(:each) do
    @response = request(resource(:layouts, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@layout, :edit)", :given => "a layout exists" do
  before(:each) do
    @response = request(resource(Layout.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@layout)", :given => "a layout exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Layout.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @layout = Layout.first
      @response = request(resource(@layout), :method => "PUT", 
        :params => { :layout => {:id => @layout.id} })
    end
  
    it "redirect to the layout show action" do
      @response.should redirect_to(resource(@layout))
    end
  end
  
end

