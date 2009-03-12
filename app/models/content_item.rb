class ContentItem < BaseModel

  # Official Schema
  property :slug
  property :title
  property :meta, :default => []
  property :content
  
  timestamps!
  unique_id :set_id
    
  # Validation
  validates_present :slug
  
  private
  def set_id
    "content_item:#{self['slug']}"
  end
end
