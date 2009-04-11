# Make sure ContentItem.use_database is called so this is hooked into a couchdb database when using
# ie ContentItem.use_database CouchRest.database!(@site.couchdb)

class ContentItem < BaseModel
  # TODO integrating with nav? how to make menu items class="active/current"?

  # Official Schema
  property :slug
  property :url
  property :title
  property :meta, :default => {}  # looks better in Futon..
  # TODO validate parts.key?("main")
  property :pieces, :default => {} # multiple pieces of content are available, "main" is the mandatory one
  # pieces => {"main" =>                 # name of the piece
  #           "Some content is in here." # the actual content to blat out
  #          }

  view_by :url, :map => <<MAP
function(doc) {
  if(doc["couchrest-type"] == "ContentItem" && doc.url && doc.title) {
    emit(doc.url, doc.title);
  }
}
MAP

  timestamps!

  # Validation
  validates_present :slug
  validates_present :url
  validates_present :title

  def to_html(piece)
    Maruku.new(self["pieces"][piece]).to_html
  end

end
