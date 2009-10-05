module Mcms
  class Misc < Application
    layout :backend
    def new_install
      render
    end
    
    def init_mcms(user)
      # make sure databse doesn't exist, prevent this being run manually
      raise NotFound if CouchRest::Server.new(Merb::Config[:couchdb_url])\
                          .databases.include?(Merb::Config[:database])
      # create the database
      CouchRest.database!(Merb::Config[:couchdb_url]\
        + "/" + Merb::Config[:database])
      User.use_database CouchRest.database(Merb::Config[:couchdb_url]\
                          + "/" + Merb::Config[:database])
      @user = User.new(user)
      if @user.save
        Mcms::Site.use_database CouchRest.database(Merb::Config[:couchdb_url]\
                                  + "/" + Merb::Config[:database])
        
        render
      end
    end
  end
end