Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  resources :layouts
  resources :page_layouts
  resources :page_layouts
  resources :themes

  
  authenticate do
    resources :sites
    match("/sites/new/existing")\
      .to(:controller => :sites, :action => :new_existing)\
      .name(:sites_new_existing)
    match("/site/:id/:rev/add_domain")\
      .to(:controller => :sites, :action => :add_domain, :method => :post)\
      .name(:site_add_domain_admin)
    resources :themes
  end
  
  # Adds the required routes for merb-auth using the password slice
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  #   1. create a new site (domain doesn't match an existing site)
  #   2. show content item that matches request
  #      (note not locked to ports or protocol, only domain.tld/blah/blah.html)
  match(%r[(^/$|^/.+$)]).defer_to do |request, params|
    site_couchdb = Site.get_couchdb(request.server_name)
    if site_couchdb.nil?
      # site doesn't exist, create one
      redirect url(:new_site)
    else
      ContentItem.use_database CouchRest.database!(site_couchdb)
      params.merge!(:url => "#{request.server_name}#{request.env["PATH_INFO"]}")
      p params[:url]
      if p = ContentItem.by_url(:key => params[:url], :limit => 1).first then
        layout_id = nil
        if p.has_layout?
          # this content_item a specific layout
          layout_id = p.layout_id
        else
          # this content_item uses the site default layout
          # first tell site config which db to use
          SiteConfig.use_database CouchRest.database!(site_couchdb)
          layout_id = Mcms::SiteConfig.get_default_layout_id
        end
        params.merge!(:controller => "mcms/page",
                      :action => :show,
                      :content_id => p.id,
                      :layout_id => layout_id)
      else
        false
      end
    end
  end

end