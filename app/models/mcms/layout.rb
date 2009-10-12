module Mcms
  # A layout is: a MCV "view", a merb "view"
  # It is the page framework, the html of the page in the browser.
  # It is where "modules" (Joomla concept) should go for now.
  #
  # A layout is assigned to to a site and there in a single "default" layout for
  # all pages which maybe overiden at the content_item level, also at the
  # content_item level an item on the layout could be overidden 
  # (not sure how yet)
  # but it solves the issue of having to create/assign a new layout
  #
  # reading a template out of couchdb on each request seems pretty ineffecient 
  # so will look to optimising later, for now just work...
  # 
  class Layout < Mcms::BaseModel
    
    # Official Schema
    property :name
    property :haml
    property :sass
    property :pieces, :default => []
    
    timestamps!
    
    # Validation
    validates_present :name
    validates_present :haml
    validates_present :sass
    validates_present :pieces
    
    # merb-cache is the conduit for getting the info out of couchdb
    # and onto the filesystem.
    # haml files are stored in :layout_haml store in app/views/temp/
    # attachements are stored in :layout_attachments store in public/temp/
    # these dirs can then be added to .gitignorebme
    # sass is exported staright out to css
    def exported_to_disk?
      # render sass and write to disk
      Sass::Plugin.update_stylesheet2(self.sass,
                                      self.id,
                                      Merb.root + "/public/stylesheets/temp/")
      # in order to include the correct stylesheet path in the haml file
      # do a string substitution looking for #layout_sass# and replacing that 
      # with /stylesheets/temp/#{layout.id}.css
      haml = self.haml.sub(/#layout_sass#/, "/stylesheets/temp/#{self.id}.css")
      return false unless Merb::Cache[:layout_haml]\
                            .write("#{self.id}.html.haml", haml)
      true
    end
    
  end
end # Mcms
