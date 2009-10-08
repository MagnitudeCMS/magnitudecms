module Mcms
  class Layouts < Application
    before :set_site_couchdb
    
    # GET /mcms/layouts
    def index
      render
    end
  
    # GET /mcms/layouts/:id
    def show
      render
    end
  
    # GET /mcms/layouts/new
    def new
      render
    end
  
    # GET /mcms/layouts/:id/edit
    def edit(id)
      Mcms::Layout.use_database CouchRest.database(@site_couchdb)
      @layout = Mcms::Layout.get(id)
      raise NotFound if @layout.nil?
      render
    end
  
    # GET /mcms/layouts/:id/delete
    def delete
      render
    end
  
    # POST /mcms/layouts
    def create
      render
    end
  
    # PUT /mcms/layouts/:id
    def update(id, layout)
      only_provides :json
    
      Mcms::Layout.use_database CouchRest.database(@site_couchdb)
      @layout = Mcms::Layout.get(id)
      unless @layout.nil?
        if @layout["_rev"].eql?(layout["rev"])
          @layout.update_attributes_without_saving(:haml => layout["haml"], :sass => layout["sass"], :name => layout["name"])          
          if @layout.save
            if @layout.exported_to_disk?
              display :success => true, :message => "Layout was successfully updated", :rev => @layout["_rev"], :id => @layout["_id"]
            else
              display :success => false, :message => "The Layout was saved, however there was an issue exporting it to disk", :rev => @layout["_rev"], :id => @layout["_id"]
            end
          else
            display :success => false, :error => @layout.errors
          end
        else
          self.status = 412
          display :error => "Update conflict", :reason => "This layout has been updated elsewhere, reload layout, then update again."
        end
      else
        self.status = 404
        display :error => "Layout Not Found", :reason => "The layout could not be found, refresh the layout list and try again."
      end
    end
  
    # DELETE /mcms/layouts/:id
    def destroy
      render
    end
  end
end # Mcms
