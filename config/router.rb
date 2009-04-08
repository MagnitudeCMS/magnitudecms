Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  
  # Adds the required routes for merb-auth using the password slice
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  # Need to make a decision here.
  #   1. create a new site (domain doesn't match an existing site)
  #   2. show content item that matches request.url
  match("/").to(:controller => "content_items", :action => "home")
end