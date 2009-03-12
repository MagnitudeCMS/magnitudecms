Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  resources :sites
  resources :content_items
  
  # Adds the required routes for merb-auth using the password slice
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  # match('/').to(:controller => 'content', :action =>'show', :slug => "")
end