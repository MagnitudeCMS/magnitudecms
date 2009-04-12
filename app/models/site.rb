class Site < BaseModel
  use_database CouchRest.database!(Merb::Config[:couchdb_url] + Merb::Config[:database])
  
  # Official Schema
  property :name
  # having multiple domains enables support for content to appear on any domain we want.
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
  # need a way to check if logged in person is an actual admin of this particular site
  property :admins, :default => []
  
  view_by :domain, :map => <<MAP
function(doc) {
  if(doc["couchrest-type"] == "Site" && doc.domains) {
    doc.domains.forEach(function(domain){    
      emit(domain, null);
    });
  }
}
MAP

  view_by :admin, :map => <<MAP
function(doc) {
  if(doc["couchrest-type"] == "Site" && doc.domains && doc.admins) {
    doc.domains.forEach(function(domain){
      doc.admins.forEach(function(admin){
        emit(admin + "|" + domain, null);
      });
    });
  }
}
MAP
  
  timestamps!
  
  # Validation
  validates_present :domains
  validates_present :default_domain
  validates_present :name
  validates_present :couchdb
  validates_present :admins

  def self.get_couchdb(domain)
    s = self.by_domain :key => domain
    return s[0].couchdb unless s.empty?
    return nil
  end
  
  def self.is_user_admin?(user,domain)
    s = self.by_admin :key => "#{user}|#{domain}", :reduce => true
    return true unless s["rows"].empty?
    return false
  end

end
