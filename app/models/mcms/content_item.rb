module Mcms
  # Make sure ContentItem.use_database is called so this is hooked into a couch
  # database when using.
  # ie ContentItem.use_database CouchRest.database!(@site.couchdb)
  class ContentItem < Mcms::BaseModel
    # TODO integrating with nav? how to make menu items class="active/current"?
  
    # Official Schema
    property :url # full URI minus the protocol & port
    property :title
    property :meta, :default => {}  # looks better in Futon.
    property :pieces, :default => {} # multiple pieces of content are available,
    property :has_layout, :cast_as => :boolean
    property :layout_id
  
    view_by :url, :map => <<MAP
function(doc) {
  if(doc["couchrest-type"] == "Mcms::ContentItem" && doc.url && doc.title) {
    emit(doc.url, doc.title);
  }
}
MAP
  
    timestamps!
  
    # Validation
    validates_present :url
    validates_present :title
    validates_present :pieces
    validates_present :meta
  
    def to_html
      self.piece_to_html("main")
    end
    
    def piece_to_html(piece)
      Maruku.new(self["pieces"][piece]).to_html
    end
    
    def get_layout(couchdb)
      Mcms::Layout.use_database CouchRest.database(couchdb)
      if self.has_layout?
        Mcms::Layout.get(self.layout_id)
      else
        Mcms::SiteConfig.use_database CouchRest.database(couchdb)
        Mcms::Layout.get(Mcms::SiteConfig.get_default_layout_id)        
      end
    end
    
  end
end