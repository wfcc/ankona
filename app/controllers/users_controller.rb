class UsersController < ApplicationController

  before_filter :require_no_user, only: [:new, :create]
  before_filter :require_user, only: [:show, :edit, :update, :destroy]

# --------------------------------------------------------------------------
  def new
    @user = User.new
  end
# --------------------------------------------------------------------------
  def create
    @user = User.new(params[:user])
    name = params[:name_handle].split(',')[0]
    case
    when name =~ /^CREATE_(.+)$/
      @user.build_author name: $1
      @user.name = $1
      flash[:notice] = "Account registered, new name recorded."
    when name.to_i > 0 && author = Author.where(code: name).first
      @user.author = author
      @user.name = author
      flash[:notice] = "Account registered."
    else  
      flash[:error] = "Name is required."
      render action: :new
      return
    end
    if @user.save
      redirect_back_or_default account_url
    else
      flash[:error] = "Error registering new account."
      render action: :new
    end
  end

# --------------------------------------------------------------------------
  def show
    @user = @current_user
  end
# --------------------------------------------------------------------------
  def edit
    @user = @current_user
    if @user.author.present?
      @author_json = [@user.author].map{|a| {id: a.id, name: a.name}}.to_json
    else
      @author_json = ''
    end
  end
# --------------------------------------------------------------------------
  def update
    @user = @current_user   
    handle = params[:name_handle]
    if handle.present?
      name = handle.split(',')[0]
      author = Author.where(code: name)    
      if author.present?
        @user.author = author[0] if author.present?
        @user.name = author[0].name
      else
        @user.build_author name: name
        @user.name = name
      end    
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      flash[:error] = "Error occurred"
      render :action => :edit
    end
  end
# --------------------------------------------------------------------------
  def destroy
    @user = @current_user
    @user.destroy

    flash[:notice] = "Account deleted!"
    redirect_to '/'
  end
end
