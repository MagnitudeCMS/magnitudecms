class Site < BaseModel
  use_database CouchRest.database!(Merb::Config[:couchdb_url] + Merb::Config[:database])
  
  # Official Schema
  property :name
  # having multiple domains enables support for content to appear on any domain we want
  # content_items are id'd by url, domain/slug, might as well be specific.
  # zero shortcuts = ultimate flexibility
  # sub-domain.domain.tld => content_item1
  # domain.tld/page2.html => content_item2
  # sub-domain.sub-domain.domain.tld/parent/category/name.html => content_item1
  property :domains, :default => []
  # need a default domain so the user doesn't need to keep typing it in all the time
  # having it separate from domain[0] enables any domain to be default
  property :default_domain
  property :couchdb

  
  timestamps!
  unique_id :set_id
  
  # Validation
  validates_present :domain
  validates_present :default_domain
  validates_present :name
  validates_present :couchdb

  private
  def set_id
    "site:#{self['default_domain']}"
  end
end
