class Sites < Application
  layout :backend
  
  # GET /sites
  def index
    @sites = Site.by_admin(:key => session.user.id)
    render
  end

  # GET /sites/:id
  def show
    render
  end

  # GET /sites/new
  def new
    @sites = Site.by_admin(:key => session.user.id)
    render
  end
  # GET /sites/new
  def new_existing
    @sites = Site.by_admin(:key => session.user.id)
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
  
  # POST /site/:id/:rev/add_domain
  def add_domain(id, rev, domain)
    @site = Site.get(id)
    if @site.rev.eql?(rev)
      @site.domains << domain
  
      if @site.save
        redirect url(:sites)
      else
        redirect url(:sites_new)
      end
    else
      
    end
  end
end
