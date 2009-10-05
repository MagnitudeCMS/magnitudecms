module Mcms
  class Misc < Application
    layout :backend
    def new_install
      render
    end
    
    def init_mcms(user)
      set_mcms_couchdb
      # make sure databse doesn't exist, prevent this being run manually
      raise NotFound if CouchRest::Server.new(Merb::Config[:couch_host])\
                          .databases.include?(Merb::Config[:couch_db])
      # create the database
      CouchRest.database!(@mcms_couchdb)
      User.use_database CouchRest.database(@mcms_couchdb)
      @user = User.new(user)
      if @user.save
        Mcms::Site.use_database CouchRest.database(@mcms_couchdb)
        
        render
      end
    end
  end
end