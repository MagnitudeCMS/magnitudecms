require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a site exists" do
  request(resource(:sites), :method => "POST", 
    :params => { :site => { :id => nil }})
end

describe "resource(:sites)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:sites))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of sites" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a site exists" do
    before(:each) do
      @response = request(resource(:sites))
    end
    
    it "has a list of sites" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      @response = request(resource(:sites), :method => "POST", 
        :params => { :site => { :id => nil }})
    end
    
    it "redirects to resource(:sites)" do
    end
    
  end
end

describe "resource(@site)" do 
  describe "a successful DELETE", :given => "a site exists" do
     before(:each) do
       @response = request(resource(Site.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:sites))
     end

   end
end

describe "resource(:sites, :new)" do
  before(:each) do
    @response = request(resource(:sites, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@site, :edit)", :given => "a site exists" do
  before(:each) do
    @response = request(resource(Site.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@site)", :given => "a site exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Site.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @site = Site.first
      @response = request(resource(@site), :method => "PUT", 
        :params => { :site => {:id => @site.id} })
    end
  
    it "redirect to the site show action" do
      @response.should redirect_to(resource(@site))
    end
  end
  
end

