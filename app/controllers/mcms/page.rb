module Mcms
  # content items are accessible via a url
  # joomla has the concept of modules and content items.
  # content items are pages and modules show up in a predefined position
  # around a content page as defined by the current "template" (layout in mcms)
  
  # What mcms does is a request comes into the router and the request is matched
  # against available content_items by url. if a match exists the id of that
  # content_item is passed to the show method of Mcms::Page.
  # Show then loads the content_item by id and loads the layout by id
  # (when a page layout is assigned to a site it is copied into the site 
  # database.
  # Layouts are documents, as such they may be sync'd. Probably if a layout 
  # is to be modified, copy it and give it a new name/id)
  class Page < Application
  
    def show(_content_id, _layout_id, _site_couchdb)
      # ensure there is a layout_id and have the layout export itself to disk
      # Not sure of an effecient way to get info out of couch and available to
      # merb's render method, so am just going to adapt to the way merb works
      raise NotFound if _layout_id.nil?
      Mcms::Layout.use_database CouchRest.database!(_site_couchdb)
      layout = Mcms::Layout.get(_layout_id)
      raise NotFound if layout.nil?
      raise NotFound unless layout.exported_to_disk?
      # even though this method ought to be invoked from the router, there is 
      # the chance it might be invoked directly so set the db again and make
      # sure a content_item doc is retrieved before proceeding
      ContentItem.use_database CouchRest.database!(_site_couchdb)
      @content_item = ContentItem.get(_content_id)
      raise NotFound if @content_item.nil?
      
      # for now only going to do html, it makes sense to do more than html
      # however the immediate requirement is that it works NOW and does html.
      # mcms::layout written out from couchdb to fs on each request, will figure
      # out a good way to cache. obviously front end caching, etags etc could be
      # used, the flexibility that is HTTP :)
      render(nil, {:format => :html, 
                   :template => "temp/#{_layout_id}",
                   :layout => false})
    end
    
  end
end # Mcms
