# use PathPrefix Middleware if :path_prefix is set in Merb::Config
if prefix = ::Merb::Config[:path_prefix]
  use Merb::Rack::PathPrefix, prefix
end

# comment this out if you are running merb behind a load balancer
# that serves static files
if Merb::Config[:merb_serve_static]
  use Merb::Rack::Static, Merb.dir_for(:public)
end

# this is our main merb application
merb = Merb::Rack::Application.new

hapong = lambda do |env|
  if env["REQUEST_METHOD"] == "OPTIONS" && env["REQUEST_URI"] == "/"
    [200, {}, "PONG!\n"]
  else
    [404, {}, "No PONG! here, move along"]
  end
end

run Rack::Cascade.new([hapong, merb])
