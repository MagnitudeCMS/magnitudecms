class Sites < Application
  layout :backend
  
  # GET /sites
  def index
    @sites = Site.by_admin_and_domain(:key => session.user.id)
    render
  end

  # GET /sites/:id
  def show
    render
  end

  # GET /sites/new
  def new
    render
  end

  # GET /sites/:id/edit
  def edit
    render
  end

  # GET /sites/:id/delete
  def delete
    render
  end

  # POST /sites
  def create(site)
    @site = Site.new(site)
    @site.default_domain = request.server_name
    @site.domains = [request.server_name]
    @site.admins = [session.user.id]

    if @site.save
      redirect url(:sites)
    else
      render :new
    end
  end

  # PUT /sites/:id
  def update
    render
  end

  # DELETE /sites/:id
  def destroy
    render
  end
end
