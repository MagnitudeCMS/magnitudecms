Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  
  match("/mcms/new_install").defer_to do |request, params|
    # make sure the default database doesn't exist. not allowed to get to this
    # route if it does
    unless CouchRest::Server.new(Merb::Config[:couchdb_url])\
            .databases.include?(Merb::Config[:database])
      params.merge!(:controller => "mcms/misc", :action => :new_install)
    else
      raise Merb::Controller::NotFound
    end
  end.name(:new_install)
  
  match("/mcms/new_install_init")\
    .to(:controller => "mcms/misc",
        :action => :init_mcms,
        :method => :post)\
    .name(:init_mcms)
  
  authenticate do
    resources :"mcms/sites"
    match("/mcms/sites/new/existing")\
      .to(:controller => "mcms/sites",
          :action     => :new_existing,
          :method     => :get)\
      .name(:"new_existing_mcms/site")
    match("/mcms/sites/:id/:rev/add_domain")\
      .to(:controller => "mcms/sites",
          :action     => :add_domain,
          :method     => :post)\
      .name(:"add_domain_admin_mcms/site")
  end
  
  # Adds the required routes for merb-auth using the password slice
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  #   1. create a new site (domain doesn't match an existing site)
  #   2. show content item that matches request
  #      (note not locked to ports or protocol, only domain.tld/blah/blah.html)
  match(%r[(^/$|^/.+$)]).defer_to do |request, params|
    # first check to see if couchdb exists for mcms
    # A goal is to not have to do anything manually, simply checkout the code,
    # set the bare minimum config (couchdb server & base db), run the app 
    # then do everything else from the browser.
    # not using database! as it creates a db if it is doesn't exist. want to
    # redirect to a "create" first user page if db doesn't exist.
    if CouchRest::Server.new(Merb::Config[:couchdb_url])\
            .databases.include?(Merb::Config[:database])
      site_couchdb = Mcms::Site.get_couchdb(request.server_name)
      
      if site_couchdb.nil?
        # site doesn't exist, create one
        redirect url(:"new_mcms/site")
      else
        ContentItem.use_database CouchRest.database!(site_couchdb)
        params.merge!(:url => "#{request.server_name}#{request.env["PATH_INFO"]}")
        p "ContentItem key: #{params[:url]}"
        if p = ContentItem.by_url(:key => params[:url], :limit => 1).first then
          # p "layout_id is nil"
          layout_id = nil
          if p.has_layout?
            # p "content_item has a layout"
            # this content_item a specific layout
            layout_id = p.layout_id
          else
            # p "content_item does not have a layout"
            # this content_item uses the site default layout
            # first tell site config which db to use
            Mcms::SiteConfig.use_database CouchRest.database!(site_couchdb)
            layout_id = Mcms::SiteConfig.get_default_layout_id
          end
          # p "layout_id is now #{layout_id}"
          params.merge!(:controller => "mcms/page",
                        :action => :show,
                        :_content_id => p.id,
                        :_layout_id => layout_id,
                        :_site_couchdb => site_couchdb)
        else
          false
        end
      end
    else
      redirect url(:new_install)
    end
  end
  
end