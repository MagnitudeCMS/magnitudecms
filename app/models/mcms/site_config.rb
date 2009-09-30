module Mcms
  class SiteConfig
    
    
    # there really ought to be only one site_config document per site db
    # thus it has fixed id, thus if another siteconfig doc is created it
    # will fail as it is not a unique id
    # probably a better way to do this...
    def self.get_default_layout_id
      self.get("thesiteconfig").default_layout_id
    end
  end
end # Mcms
