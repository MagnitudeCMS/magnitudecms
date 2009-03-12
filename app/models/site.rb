class Site < BaseModel
  use_database CouchRest.database!(Merb::Config[:couchdb_url] + Merb::Config[:database])
  
  # Official Schema
  property :name
  property :domain
  property :couchdb

  
  timestamps!
  unique_id :set_id
  
  # Validation
  validates_present :domain
  validates_present :name
  validates_present :couchdb

  private
  def set_id
    "site:#{self['domain']}"
  end
end
