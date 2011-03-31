# coding: utf-8
class AuthorsController < ApplicationController

  before_filter :require_admin, except: [:index, :show, :json]

  # GET /authors
  def index
    @@pagination_options = {inner_window: 10, outer_window: 10}
    search = "%#{params[:search_name]}%"
    #  .where(:source.eq => 'h')
    @authors = Author
      .where((:name =~ search) | (:code =~ search) |
        (:original =~ search) | (:traditional =~ search))
      .order(:code)
      .page(params[:page]).per(100)

    store_location
  end
#----------------------------------------------------------------------
  def json

    q = params[:q]
    search = "%#{q}%"
    handle = params[:handle].present? # return either IDs or handles
    authors = [name: "not found «#{q}», create", id: "CREATE_#{q}"]
    authors += Author
      .where((:name =~ search) | (:code =~ search) |
        (:original =~ search) | (:traditional =~ search))
      .map{|a| {name: a.name, id: (handle ? a.code: a.id)}}
    render json: authors
  #logger.info '*** 2 ************************* '
  #logger.info @authors
  end
# GET /authors/1------------------------------------------------------
  def show
    @author = Author.find(params[:id])
  end
# GET /authors/new ----------------------------------------------------------
  def new
    @author = Author.new
    render :edit
  end
# GET /authors/1/edit -------------------------------------------------------
  def edit
    @author = Author.find(params[:id])
  end
# POST /authors ------------------------------------------------------------
  def create
    @author = Author.new(params[:author])

    if @author.save
      flash[:notice] = 'Author was successfully created.'
      redirect_to @author
    else
      render action: "new"
    end
  end

  # PUT /authors/1
  def update
    @author = Author.find(params[:id])

    if is_admin? and @author.update_attributes(params[:author])
      if params[:code]['regenerate'] == '1'
        @author.code = ''
        @author.save
      end
      flash[:notice] = 'Author was successfully updated.'
      redirect_to @author
    else
      render :action => "edit"
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
