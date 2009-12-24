class CollectionsController < ApplicationController
  # GET /collections
  # GET /collections.xml
  before_filter :require_user, :only => [:destroy, :edit, :show]

  def index
    case
    when (is_admin?)
      @collections = Collection.all
    when (current_user)
      @collections = current_user.collections.all
    else
      flash[:error] = 'Only registered and logged in users can manage collections.'
      redirect_to login_path
      return
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @collections }
    end
  end

  # GET /collections/1
  # GET /collections/1.xml
  def show
    @collection = Collection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @collection }
    end
  end

  # GET /collections/new
  # GET /collections/new.xml
  def new
    @collection = Collection.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collection }
    end
  end

  # GET /collections/1/edit
  def edit
    @collection = Collection.find(params[:id])
  end

  # POST /collections
  # POST /collections.xml
  def create
    @collection = Collection.new(params[:collection])

    respond_to do |format|
      unless current_user_session
        flash[:error] = 'You could do that if you were logged in. But you aren\'t, so you can\'t.'
        redirect_to login_path
      else
        @collection.user = current_user
        if @collection.save
          flash[:notice] = 'Collection was successfully created.'
          format.html { redirect_to(collection_url) }
          format.xml  { render :xml => @collection, :status => :created, :location => @collection }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @collection.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /collections/1
  # PUT /collections/1.xml
  def update
    @collection = Collection.find(params[:id])

    respond_to do |format|
      if @collection.update_attributes(params[:collection])
        flash[:notice] = 'Collection was successfully updated.'
        format.html { redirect_to(collections_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @collection.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.xml
  def destroy
    @collection = Collection.find(params[:id])
    if may_edit? @collection
      @collection.destroy
      flash[:notice] = "Collection deleted."
      respond_to do |format|
        format.html { redirect_to(collections_url) }
        format.xml  { head :ok }
      end
    else
      flash[:error] = "You can not do that."
      redirect_to collections_url
    end
  end
end
