require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a content_item exists" do
  request(resource(:content_item), :method => "POST", 
    :params => { :content_item => { :id => nil }})
end

describe "resource(:content_item)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:content_item))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of content_item" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a content_item exists" do
    before(:each) do
      @response = request(resource(:content_item))
    end
    
    it "has a list of content_item" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      @response = request(resource(:content_item), :method => "POST", 
        :params => { :content_item => { :id => nil }})
    end
    
    it "redirects to resource(:content_item)" do
    end
    
  end
end

describe "resource(@content_item)" do 
  describe "a successful DELETE", :given => "a content_item exists" do
     before(:each) do
       @response = request(resource(ContentItem.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:content_item))
     end

   end
end

describe "resource(:content_item, :new)" do
  before(:each) do
    @response = request(resource(:content_item, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@content_item, :edit)", :given => "a content_item exists" do
  before(:each) do
    @response = request(resource(ContentItem.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@content_item)", :given => "a content_item exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(ContentItem.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @content_item = ContentItem.first
      @response = request(resource(@content_item), :method => "PUT", 
        :params => { :content_item => {:id => @content_item.id} })
    end
  
    it "redirect to the content_item show action" do
      @response.should redirect_to(resource(@content_item))
    end
  end
  
end

