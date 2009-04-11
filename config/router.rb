Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  
  authenticate do
    resources :sites
  end
  
  # Adds the required routes for merb-auth using the password slice
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  # Need to make a decision here.
  #   1. create a new site (domain doesn't match an existing site)
  #   2. show content item that matches /
  match("/").defer_to do |request, params|
    @site_couchdb = Site.get_couchdb(request.server_name)
    if @site_couchdb.nil?
      # site doesn't exist, create one
      redirect url(:new_site)
    else
      # site exists, show page
      params.merge(:controller => "content_items", :action => :show, :slug => "#{request.server_name}/")
    end
  end
  
end