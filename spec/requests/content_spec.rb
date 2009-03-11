require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a content exists" do
  request(resource(:content), :method => "POST", 
    :params => { :content => { :id => nil }})
end

describe "resource(:content)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:content))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of content" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a content exists" do
    before(:each) do
      @response = request(resource(:content))
    end
    
    it "has a list of content" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      @response = request(resource(:content), :method => "POST", 
        :params => { :content => { :id => nil }})
    end
    
    it "redirects to resource(:content)" do
    end
    
  end
end

describe "resource(@content)" do 
  describe "a successful DELETE", :given => "a content exists" do
     before(:each) do
       @response = request(resource(Content.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:content))
     end

   end
end

describe "resource(:content, :new)" do
  before(:each) do
    @response = request(resource(:content, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@content, :edit)", :given => "a content exists" do
  before(:each) do
    @response = request(resource(Content.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@content)", :given => "a content exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Content.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @content = Content.first
      @response = request(resource(@content), :method => "PUT", 
        :params => { :content => {:id => @content.id} })
    end
  
    it "redirect to the content show action" do
      @response.should redirect_to(resource(@content))
    end
  end
  
end

