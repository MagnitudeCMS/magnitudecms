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
gem "thin", "1.2.2"
 
# orm
gem "mattetti-couchrest", "0.34", :require_as => "couchrest"
 
# view
gem "merb_viewfu", "0.3.4"
gem "maruku", "0.6.0"
gem "haml", "2.2.0"
gem "merb-haml", merb_gems_version
gem "chriseppstein-compass", "0.8.16", :require_as => "compass"
gem "chriseppstein-compass-960-plugin", "0.9.8", :require_as => "ninesixty"
 
# testing
gem "auxesis-webrat", "0.4.1", :require_as => "webrat"
gem "cucumber", "0.3.11"
gem "chronic", "0.2.3"
gem "ParseTree", "3.0.3", :require_as => 'parse_tree'
gem "rspec", "1.2.8", :require_as => 'spec'
gem "david-merb_cucumber", :require_as => "merb_cucumber"
