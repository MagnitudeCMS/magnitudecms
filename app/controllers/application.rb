class Application < Merb::Controller
  
  def ensure_admin
    raise Unauthorized unless Site.is_user_admin?(session.user.email,request.server_name)
  end
  
end
