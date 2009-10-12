module Mcms
  class ContentItems < Application
    before :set_site_couchdb
    before :ensure_site_admin
    layout :backend
    
    # GET /content_items
    def index
      Mcms::ContentItem.use_database CouchRest.database(@site_couchdb)
      @content_items = Mcms::ContentItem.by_url
      render
    end
  
    # GET /content_items/:id
    def show
      render
    end
  
    # GET /content_items/new
    def new
      Mcms::SiteConfig.use_database CouchRest.database(@site_couchdb)
      Mcms::Layout.use_database CouchRest.database(@site_couchdb)
      @layout = Mcms::Layout.get(Mcms::SiteConfig.get_default_layout_id)
      render :layout => nil
    end
  
    # GET /content_items/:id/edit
    def edit(id)
      Mcms::ContentItem.use_database CouchRest.database(@site_couchdb)
      @content_item = Mcms::ContentItem.get(id)
      raise NotFound if @content_item.nil?
      render :layout => nil
    end
  
    # GET /content_items/:id/delete
    def delete
      render
    end
  
    # POST /content_items
    def create(content_item)
      only_provides :json
      
      Mcms::ContentItem.use_database CouchRest.database(@site_couchdb)
      @content_item = Mcms::ContentItem.new(
            :pieces => content_item["pieces"],
            :title => content_item["title"],
            :url => content_item["url"],
            :meta => content_item["meta"])
      if @content_item.save
        display :success => true, :message => "ContentItem was successfully updated", :url => absolute_url(:"edit_mcms/content_item", @content_item["_id"]), :action => "created"
      else
        self.status = 500
        display :success => false, :error => @content_item.errors
      end
    end
  
    # PUT /content_items/:id
    def update(id, content_item)
      only_provides :json
    
      Mcms::ContentItem.use_database CouchRest.database(@site_couchdb)
      @content_item = Mcms::ContentItem.get(id)
      unless @content_item.nil?
        if @content_item["_rev"].eql?(content_item["rev"])
          @content_item.update_attributes_without_saving(
            :pieces => content_item["pieces"],
            :title => content_item["title"],
            :url => content_item["url"],
            :meta => content_item["meta"])
          if @content_item.save
            display :success => true, :message => "ContentItem was successfully updated", :rev => @content_item["_rev"], :id => @content_item["_id"], :action => "updated"
          else
            self.status = 500
            display :success => false, :error => @content_item.errors
          end
        else
          self.status = 412
          display :error => "Update conflict", :reason => "This content_item has been updated elsewhere, reload content_item, then update again."
        end
      else
        self.status = 404
        display :error => "ContentItem Not Found", :reason => "The content_item could not be found, refresh the content_item list and try again."
      end
    end
  
    # DELETE /content_items/:id
    def destroy(id, rev)
      only_provides :json
    
      Mcms::ContentItem.use_database CouchRest.database(@site_couchdb)
      @content_item = Mcms::ContentItem.get(id)
      unless @content_item.nil?
        if @content_item["_rev"].eql?(rev)
          if @content_item.destroy
            display :success => true, :message => "ContentItem was successfully deleted", :action => "deleted"
          else
            self.status = 500
            display :success => false, :error => @content_item.errors
          end
        else
          self.status = 412
          display :error => "Update conflict", :reason => "This content_item has been updated elsewhere, reload content_item, then update again."
        end
      else
        self.status = 404
        display :error => "ContentItem Not Found", :reason => "The content_item could not be found, refresh the content_item list and try again."
      end
    end
    
  end
end