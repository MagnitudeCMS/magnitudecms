require 'rubygems'
require 'rake/rdoctask'

require 'merb-core'
require 'merb-core/tasks/merb'

include FileUtils

# Load the basic runtime dependencies; this will include 
# any plugins and therefore plugin rake tasks.
init_env = ENV['MERB_ENV'] || 'rake'
Merb.load_dependencies(:environment => init_env)
     
# Get Merb plugins and dependencies
Merb::Plugins.rakefiles.each { |r| require r } 

# Load any app level custom rakefile extensions from lib/tasks
tasks_path = File.join(File.dirname(__FILE__), "lib", "tasks")
rake_files = Dir["#{tasks_path}/*.rake"]
rake_files.each{|rake_file| load rake_file }

desc "Start runner environment"
task :merb_env do
  Merb.start_environment(:environment => init_env, :adapter => 'runner')
end

require 'spec/rake/spectask'
require 'merb-core/test/tasks/spectasks'
desc 'Default: run spec examples'
task :default => 'spec'

##############################################################################
# ADD YOUR CUSTOM TASKS IN /lib/tasks
# NAME YOUR RAKE FILES file_name.rake
##############################################################################

desc 'after doing a gem bundle --cached and updating application.yml run this task and set a hosts entry for site1, then open your browser'
task :gogogooo => [:merb_env] do
  server = CouchRest::Server.new(Merb::Config[:couchdb_url])
  server.database!(Merb::Config[:database])
  user = User.create(:email => "a@a.com", :password => "123", :password_confirmation => "123")
  site = Site.create(:name => "site1", :default_domain => "site1", :couchdb => "#{Merb::Config[:couchdb_url]}/#{Merb::Config[:database]}_site1",:domains => ["site1"], :admins => [user.id])
  ContentItem.use_database CouchRest.database!(site.couchdb)
  ContentItem.create(:title => "Home", :url => "site1/", :pieces => {:main => "home page"})
  Mcms::Layout.use_database CouchRest.database!(site.couchdb)
  layout = Mcms::Layout.create(:name => "default", :haml => "!!! XML\n!!!\n%html{ html_attrs('en-AU') }\n  %head\n    %meta{ :content => \"text/html; charset=utf-8\", :\"http-equiv\" => \"content-type\" }\n    %title= @content_item.title\n    %link{ :href => \"#layout_sass#\", :rel => \"stylesheet\", :type => \"text/css\"}\n  %body\n    #content= @content_item.to_html\n", :sass => "#content\n  :color #f0f\n")
  Mcms::SiteConfig.use_database CouchRest.database!(site.couchdb)
  Mcms::SiteConfig.create(:"_id" => "thesiteconfig", :layouts => [layout.id])
end
