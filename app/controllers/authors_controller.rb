class AuthorsController < ApplicationController

  before_filter :require_admin, except: [:index, :show]

  # GET /authors
  def index

    @@pagination_options = {inner_window: 10, outer_window: 10}
    @authors = Author
      .where(:source.eq => 'h')
      .where(:name.matches % "%#{params[:search_name]}%")
      .paginate(
        page: params[:page],
        per_page: 99 
        )

    store_location
    logger.info '*** ' + request.request_uri + ' ***'
  end

  # GET /authors/1
  def show
    @author = Author.find(params[:id])
  end

  # GET /authors/new
  def new
    @author = Author.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @author }
    end
  end

  # GET /authors/1/edit
  def edit
    @author = Author.find(params[:id])
    @hideIfNonroman = @author.original.blank? ? 'display:visible' : 'display:none'
    @showIfNonroman = @author.original.blank? ? 'display:none' : 'display:visible'
  end

  # POST /authors
  def create
    @author = Author.new(params[:author])

    respond_to do |format|
      if @author.save
        flash[:notice] = 'Author was successfully created.'
        format.html { redirect_to(@author) }
        format.xml  { render :xml => @author, :status => :created, :location => @author }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @author.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /authors/1
  def update
    @author = Author.find(params[:id])

    respond_to do |format|
      if is_admin? and @author.update_attributes(params[:author])
        if params[:code]['regenerate'] == '1'
          @author.code = ''
          @author.save
        end
        flash[:notice] = 'Author was successfully updated.'
        format.html { redirect_to(@author) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @author.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /authors/1
  def destroy
    @author = Author.find(params[:id])
    @author.destroy

    respond_to do |format|
      format.html { redirect_to(authors_url) }
      format.xml  { head :ok }
    end
  end
end
