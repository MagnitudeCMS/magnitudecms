# content items are accessible via a url
# joomla has the concept of modules and content items.
# content items are pages and modules show up in a predefined position
# around a content page as defined by the current "template" (layout in mcms)

# What mcms does is a request comes into the router and the request is matched
# against available content_items by url. if a match exists the id of that
# content_item is passed to the show method of Mcms::Page.
# Show then loads the content_item by id and loads the layout by id
# (when a page layout is assigned to a site it is copied into the site database.
#  Layouts are documents, as such they may be sync'd. Probably if a layout 
#  is to be modified, copy it and give it a new name/id)

module Mcms
  class Page < Application
  
    def show(content_id, layout_id)
      render
    end
    
  end
end # Mcms
