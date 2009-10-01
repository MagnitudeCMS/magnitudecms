bundle_path "gems"
source "http://gems.github.com"

merb_gems_version = "1.1"

gem "merb-core", merb_gems_version
gem "merb-action-args", merb_gems_version
gem "merb-assets", merb_gems_version
gem("merb-cache", merb_gems_version) do
  Merb::Cache.setup do
    register(Merb::Cache::FileStore) unless Merb.cache
  end
end
gem "merb-helpers", merb_gems_version
gem "merb-mailer", merb_gems_version
gem "merb-slices", merb_gems_version
gem "merb-auth-core", merb_gems_version
gem "merb-auth-more", merb_gems_version
gem "merb-auth-slice-password", merb_gems_version
gem "merb-param-protection", merb_gems_version
gem "merb-exceptions", merb_gems_version
gem "merb-gen", merb_gems_version

# webserver
gem "thin", "1.0.0"

# datastore
gem "jchris-couchrest", "0.23.0", :require_as => "couchrest"

# view
gem "merb_viewfu", "0.3.2"
gem "maruku", "0.5.9"
gem "haml", "2.1.0", :source => "http://gems.nicholasorr.com"
gem "merb-haml", merb_gems_version
gem "chriseppstein-compass", "0.6.1", :require_as => "compass"
gem "chriseppstein-compass-960-plugin", "0.9.4", :require_as => "ninesixty"

# testing
gem "cucumber", "0.1.16"
gem "auxesis-webrat", "0.4.1", :require_as => "webrat"
gem "david-merb_cucumber", "0.5.1.2", :require_as => "merb_cucumber"
