# dependencies are generated using a strict version, don't forget to edit the dependency versions when upgrading.
merb_gems_version = "1.0.9"

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

dependency "mongrel"
dependency "merb_viewfu"

dependency "maruku"
# $ gem sources -a http://gems.nicholasorr.com
dependency "haml", "~>2.1.0"
dependency "merb-haml", merb_gems_version
dependency "chriseppstein-compass", "0.5.0", :require_as => "compass"

dependency "jchris-couchrest", "0.2.2", :require_as => "couchrest"

# testing
dependency "cucumber"
# $ gem sources -a http://gems.github.com
dependency "auxesis-webrat", "0.4.1", :require_as => "webrat"
dependency "david-merb_cucumber", :require_as => "merb_cucumber"