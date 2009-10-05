module Mcms
  class Backend < Application
    layout :backend
    # not sure how to get the admin controlls to show up on the frontend yet
    # so for now do a simple backend page/controller
    def index
      render
    end
    
  end
end # Mcms
