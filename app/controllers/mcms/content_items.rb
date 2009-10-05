module Mcms
  class ContentItems < Application
    before :set_site_couchdb
    layout :backend
    
    # GET /content_items
    def index
      Mcms::ContentItem.use_database CouchRest.database(@site_couchdb)
      @content_items = Mcms::ContentItem.by_url
      render
    end
  
    # GET /content_items/:id
    def show(id)
      render
    end
  
    # GET /content_items/new
    def new
      render
    end
  
    # GET /content_items/:id/edit
    def edit
      render
    end
  
    # GET /content_items/:id/delete
    def delete
      render
    end
  
    # POST /content_items
    def create
      render
    end
  
    # PUT /content_items/:id
    def update
      render
    end
  
    # DELETE /content_items/:id
    def destroy
      render
    end
    
  end
end