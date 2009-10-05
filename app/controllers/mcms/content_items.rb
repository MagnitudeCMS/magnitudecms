module Mcms
  class ContentItems < Application
    
    # GET /content_items
    def index
      render
    end
  
    # GET /content_items/:id
    def show(id)
      @content = ContentItem.get(id)
      raise NotFound if @content.nil?
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