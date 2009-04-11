merb_gems_version = "1.0.10"

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

# webserver
dependency "thin", "1.0.0"

# datastore
dependency "jchris-couchrest", "0.23.0", :require_as => "couchrest", :source => "http://gems.github.com"

# view
dependency "merb_viewfu", "0.3.2"
dependency "maruku", "0.5.9"
dependency "haml", "2.1.0", :source => "http://gems.nicholasorr.com"
dependency "merb-haml", merb_gems_version
dependency "chriseppstein-compass", "0.6.1", :require_as => "compass", :source => "http://gems.github.com"
dependency "chriseppstein-compass-960-plugin", "0.9.4", :require_as => "ninesixty"

# testing
dependency "cucumber", "0.1.16"
dependency "auxesis-webrat", "0.4.1", :require_as => "webrat", :source => "http://gems.github.com"
dependency "david-merb_cucumber", "0.5.1.2", :require_as => "merb_cucumber", :source => "http://gems.github.com"
