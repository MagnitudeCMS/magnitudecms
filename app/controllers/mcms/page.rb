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
  # database. The idea was to use couchdb replication funcitonallity however
  # replication filtering is not in couchdb yet, for now it will be handled by
  # the layout model/controller)
  class Page < Application
  
    def show(_content_id, _layout_id, _site_couchdb)
      # even though this method ought to be invoked from the router, there is 
      # the chance it might be invoked directly so set the db again and make
      # sure a content_item doc is retrieved before proceeding
      Mcms::ContentItem.use_database CouchRest.database(_site_couchdb)
      @content_item = ContentItem.get(_content_id)
      raise NotFound if @content_item.nil?
      
      # for now only going to do html, it makes sense to do more than html
      # however the immediate requirement is that it works NOW and does html.
      # mcms::layout written out from couchdb to fs on each request, will figure
      # out a good way to cache. obviously front end caching, etags etc could be
      # used, the flexibility that is HTTP :)
      @valid_admin = site_admin?
      render(nil, {:format => :html, 
                   :template => "temp/#{_layout_id}",
                   :layout => false})
    end
    
  end
end # Mcms
