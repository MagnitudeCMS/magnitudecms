# Go to http://wiki.merbivore.com/pages/init-rb
 
require "config/dependencies.rb"
 
#use_orm :none
use_test :rspec
use_template_engine :haml

Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = "cookie"  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # Compass config
  c[:compass] = {
    :stylesheets => 'app/stylesheets',
    :compiled_stylesheets => 'public/stylesheets'
  }
  
  # cookie session store configuration
  c[:session_secret_key]  = "2f8b2c7ecoubvwa10u0hdQOEF-137dc46e"  # required for cookie session store
  c[:session_id_key] = "_mcms_sid" # cookie session id key, defaults to "_session_id"
  
  config_file = File.join(Merb.root, "config", "application.yml")
  if File.exists?(config_file)
    config = YAML.load(File.read(config_file))[Merb.environment]
    config.keys.each do |key|
      c[key.to_sym] = config[key]
    end
  end
end
 
Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  
  # fixerupper for http://is.gd/mElL
  class Merb::Authentication
    module Mixins
      module SaltedUser
        module InstanceMethods
          def encrypt_password
            return if password.blank?
            self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{Merb::Authentication::Strategies::Basic::Base.login_param}--") if self.salt.nil?
            self.crypted_password = encrypt(password)
          end
        end # InstanceMethods
      end # SaltedUser    
    end # Mixins
  end # Merb::Authentication
end
