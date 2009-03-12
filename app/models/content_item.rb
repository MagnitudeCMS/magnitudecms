# Make sure ContentItem.use_database is called so this is hooked into a couchdb database when using
# ie ContentItem.use_database CouchRest.database!(@site.couchdb)

class ContentItem < BaseModel

  # Official Schema
  property :slug
  property :title
  property :meta, :default => {}  # looks better in Futon..
  # TODO validate parts.key?("main")
  property :pieces, :default => {} # multiple pieces of content are available, "main" is the mandatory one
  # pieces => {"main" =>                 # name of the piece
  #           "Some content is in here." # the actual content to blat out
  #          }

  timestamps!
  unique_id :set_id

  # Validation
  validates_present :slug
  validates_present :title

  def to_html(piece)
    Maruku.new(self["pieces"][piece]).to_html
  end

  private
  def set_id
    "content_item:#{self['slug']}"
  end
end
