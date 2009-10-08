# Go to http://wiki.merbivore.com/pages/init-rb
 
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
    unless config.nil?
      config.keys.each do |key|
        c[key.to_sym] = config[key]
      end
    end
  end
end
 
Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
  
  # Tweak Sass so it can use a string input instead of a file for compiling sass
  module Sass
    module Plugin
      extend self
      def update_stylesheet2(sass, name, css_location)
        css = css_filename(name, css_location)
        File.delete(css) if File.exists?(css)
  
        result = begin
                   Sass::Files.tree_for2(sass, name, engine_options(:css_filename => css, :filename => name)).render
                 rescue Exception => e
                   exception_string(e)
                 end

        # Create any directories that might be necessary
        mkpath(css_location, name)
  
        # Finally, write the file
        File.open(css, 'w') do |file|
          file.print(result)
        end
      end
    end
    module Files
      extend self
      def tree_for2(_input, filename, options)
        options = Sass::Engine::DEFAULT_OPTIONS.merge(options)
        text = _input
  
        if options[:cache]
          compiled_filename = sassc_filename(filename, options)
          sha = Digest::SHA1.hexdigest(text)
  
          if root = try_to_read_sassc(filename, compiled_filename, sha)
            root.options = options.merge(:filename => filename)
            return root
          end
        end
        engine = Sass::Engine.new(text, options.merge(:filename => filename))
        begin
          root = engine.to_tree
        rescue Sass::SyntaxError => err
          err.add_backtrace_entry(filename)
          raise err
        end
        try_to_write_sassc(root, compiled_filename, sha, options) if options[:cache]
        root
      end
    end
  end
  # Tweak Sass so it can use a string input instead of a file for compiling sass
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
  
  Merb::Cache.setup do
    register(:layout_haml, Merb::Cache::FileStore, :dir => Merb.root / "app" / "views" / "temp")
  end
end
