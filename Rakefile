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

task :copy_cucumber_bin do 
  bin = Dir.glob(Merb.root / "gems" / "gems" / "cucumber*").last / "bin" / "cucumber"
  File.open(bin, 'w') do |f|
    cucumber_bin = <<-EOS
#!/usr/bin/env ruby
# Add '.rb' to work around a bug in IronRuby's File#dirname
#\$:.unshift(File.dirname(__FILE__ + '.rb') + '/../lib') unless $:.include?(File.dirname(__FILE__ + '.rb') + '/../lib')
#
#require 'cucumber/cli'
#Cucumber::CLI.execute(ARGV)

# FIXME: bit hacky - should be getting rake task to call bin/cucumber instead of this

begin
  require 'minigems'
rescue LoadError
  require 'rubygems'
end

if File.directory?(gems_dir = File.join(Dir.pwd, 'gems')) ||
   File.directory?(gems_dir = File.join(File.dirname(__FILE__), '..', 'gems'))
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(gems_dir)
end

require 'cucumber/cli'
Cucumber::CLI.execute ARGV
    EOS
    f << cucumber_bin
  end
end