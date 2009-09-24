# Explicit versions keep things sane
merb_gems_version = "1.0.11"

dependency "merb-core", merb_gems_version
dependency "merb-action-args", merb_gems_version
dependency "merb-assets", merb_gems_version
dependency("merb-cache", merb_gems_version) do
  Merb::Cache.setup do
    register(Merb::Cache::FileStore) unless Merb.cache
  end
end
dependency "merb-helpers", merb_gems_version
dependency "merb-mailer", merb_gems_version
dependency "merb-slices", merb_gems_version
dependency "merb-auth-core", merb_gems_version
dependency "merb-auth-more", merb_gems_version
dependency "merb-auth-slice-password", merb_gems_version
dependency "merb-param-protection", merb_gems_version
dependency "merb-exceptions", merb_gems_version
dependency "merb-gen", merb_gems_version
dependency "thor", "0.9.9"

# webserver
dependency "thin", "1.2.2"

# datastore
dependency "couchrest", "0.33"

# view
dependency "merb_viewfu", "0.3.4"
dependency "maruku", "0.6.0"
dependency "haml", "2.2.0"
dependency "merb-haml", merb_gems_version
dependency "chriseppstein-compass", "0.8.16", :require_as => "compass"
dependency "chriseppstein-compass-960-plugin", "0.9.8", :require_as => "ninesixty"

# testing
dependency "auxesis-webrat", "0.4.1", :require_as => "webrat"
dependency "cucumber", "0.3.102"
