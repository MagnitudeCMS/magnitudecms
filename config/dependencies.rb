# dependencies are generated using a strict version, don't forget to edit the dependency versions when upgrading.
merb_gems_version = "1.0.10"

# For more information about each component, please read http://wiki.merbivore.com/faqs/merb_components
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
dependency "thin"

# datastore
dependency "jchris-couchrest", "0.23.0", :require_as => "couchrest"   # $ gem sources -a http://gems.github.com

# view
dependency "merb_viewfu"
dependency "maruku"
dependency "haml", "2.1.0"                                            # $ gem sources -a http://gems.nicholasorr.com
dependency "merb-haml", merb_gems_version
dependency "chriseppstein-compass", "0.6.1", :require_as => "compass" # $ gem sources -a http://gems.github.com

# testing
dependency "cucumber"
dependency "auxesis-webrat", "0.4.1", :require_as => "webrat"         # $ gem sources -a http://gems.github.com
dependency "david-merb_cucumber", :require_as => "merb_cucumber"      # $ gem sources -a http://gems.github.com
