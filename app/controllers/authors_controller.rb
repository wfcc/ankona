# coding: utf-8
class AuthorsController < NonauthorizedController

  def index
    @@pagination_options = {inner_window: 10, outer_window: 10}
    search = "%#{params[:search_name]}%"
    #  .where(:source.eq => 'h')
    @authors = Author
      .where{(name =~ search) | (code =~ search) |
        (original =~ search) | (traditional =~ search)}
      .order(:code)
      .paginate page: params[:page], per_page: 99
#      .page(params[:page]).per(100)

    #store_location

  end
#----------------------------------------------------------------------
  def json

    q = params[:q]
    search = "%#{q}%"
    handle = params[:handle].present? # return either IDs or handles
    authors = q =~ /.. ../ ? 
      [name: "#{q} <span style='font-size:smaller'>(will be created)</span>", id: "CREATE_#{q}"] : []
    authors += Author
      .where{(name =~ search) | (code =~ search) |
        (original =~ search) | (traditional =~ search)}
      .map{|a| {name: a.name, id: (handle ? a.code: a.id)}}
    render json: authors
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

    if @author.update_attributes(params[:author])
      if params[:code]['regenerate'] == '1'
        @author.code = ''
        @author.save
      end
      flash[:notice] = 'Author was successfully updated.'
      redirect_to @author
    else
      render action: :edit
    end
  end

  # DELETE /authors/1
  def destroy
    @author = Author.find(params[:id])
    @author.destroy

    redirect_to(authors_url)
  end
end
