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
    
    def exported_to_disk?
      # sass files are dumped into app/stylesheets/temp
      # and a layout_#{id}.sass is written to app
      # no need to do anything in the haml/html to get the paths correct,
      # everything is taken care of by replacing /stylesheets/ with the
      # correct path.
      return false unless self.write_to_disk(self.haml, path)
      return false unless self.write_to_disk(self.sass, Merb.root)
      true
    end
    
    private    
    def write_to_disk(content, path)
    
      path = File.join(Sinatra::Application.root ,Sinatra::Application.public, "s")
      # Create the directory if it doesn't exist
      Dir.mkdir(path) unless File.exists?(path) && File.directory?(path)
      File.open(File.join(path, "/#{params[:name]}.css"), "w+") {|f| f.write(output)}
    end
  end
end # Mcms
