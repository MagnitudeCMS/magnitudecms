class Application < Merb::Controller
  
  def ensure_site_admin
    raise Unauthorized unless Site.is_user_site_admin?(session.user.email,request.server_name)
  end
  
  def set_site_couchdb
    @site_couchdb = Mcms::Site.get_couchdb(request.server_name)
  end
  
end
