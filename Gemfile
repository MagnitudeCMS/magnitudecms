source :gemcutter
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
gem "json_pure", "1.1.9", :require => "json"
gem "mattetti-couchrest", "0.34", :require => "couchrest"
 
# view
gem "merb_viewfu", "0.3.4"
gem "maruku", "0.6.0"
gem "haml", "2.2.0"
gem "merb-haml", merb_gems_version
gem "chriseppstein-compass", "0.8.16", :require => "compass"
gem "chriseppstein-compass-960-plugin", "0.9.8", :require => "ninesixty"
