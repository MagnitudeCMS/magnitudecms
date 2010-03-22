module Mcms
  class Sites < Application
    layout :backend
    
    # GET /sites
    def index
      @sites = Mcms::Site.by_admin(:key => session.user.id)
      render
    end
  
    # GET /sites/:id
    def show
      render
    end
  
    # GET /sites/new
    def new
      @sites = Mcms::Site.by_admin(:key => session.user.id)
      render
    end
    # GET /sites/new
    def new_existing
      @sites = Mcms::Site.by_admin(:key => session.user.id)
      render
    end
  
    # GET /sites/:id/edit
    def edit
      render
    end
  
    # GET /sites/:id/delete
    def delete
      render
    end
  
    # POST /sites
    def create(site)
      @site = Mcms::Site.new(site)
      @site.default_domain = request.server_name
      @site.domains = [request.server_name]
      @site.admins = [session.user.id]
  
      if @site.save
        Mcms::ContentItem.use_database CouchRest.database!(@site.couchdb)
        Mcms::ContentItem.create(:title => "Home", :url => "#{@site.default_domain}/", :pieces => {:main => "home page"}, :meta => {:description => "", :keywords => ""} )
        Mcms::Layout.use_database CouchRest.database(@site.couchdb)
        layout = Mcms::Layout.create(:name => "default", :pieces => ["main"], :haml => "!!! XML\n!!!\n%html{ html_attrs('en-AU') }\n  %head\n    %meta{ :content => \"text/html; charset=utf-8\", :\"http-equiv\" => \"content-type\" }\n    %title= @content_item.title\n    %link{ :href => \"#layout_sass#\", :rel => \"stylesheet\", :type => \"text/css\"}\n  %body\n    #content= @content_item.to_html\n", :sass => "#content\n  :color #f0f\n")
        Mcms::SiteConfig.use_database CouchRest.database(@site.couchdb)
        Mcms::SiteConfig.create(:"_id" => "thesiteconfig", :layouts => [layout.id])
        redirect("/")
      else
        render :new
      end
    end
  
    # PUT /sites/:id
    def update
      
      render
    end
  
    # DELETE /sites/:id
    def destroy
      render
    end
    
    # POST /site/:id/:rev/add_domain
    def add_domain(id, rev, domain)
      @site = Mcms::Site.get(id)
      if @site.rev.eql?(rev)
        @site.domains << domain
    
        if @site.save
          redirect("/")
        else
          render :new
        end
      else
        
      end
    end
  end
end