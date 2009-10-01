module Mcms
  # Make sure SiteConfig.use_database is called so this is hooked into a couch
  # database when using.
  # ie SiteConfig.use_database CouchRest.database!(@site.couchdb)
  class SiteConfig < Mcms::BaseModel
    
    # Official Schema
    property :layouts, :default => [] # an array of layout id's,
                                      # element 0 is the default
    
    # there really ought to be only one site_config document per site db
    # thus it has fixed id, thus if another siteconfig doc is created it
    # will fail as it is not a unique id
    # probably a better way to do this...
    def self.get_default_layout_id
      site_config = self.get("thesiteconfig")
      return nil if site_config.nil? # safety, ought to be throwing errors.
                                     # issue with that is i don't know how it 
                                     # should be done...
      site_config.layouts[0]
    end
  end
end # Mcms
