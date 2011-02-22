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
      if @user.save
        flash[:notice] = "Account registered!"
        redirect_back_or_default account_url
      else
        render action: :new
      end
    else
      flash[:error] = "Name is required"
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
    @author_json = [@user.author].map{|a| {id: a.id, name: a.name}}.to_json
  end
# --------------------------------------------------------------------------
  def update
    @user = @current_user   
    handle = params[:name_handle]
    if handle.present?
      name = handle.split(',')[0]
      author = Author.where(code: name)    
      logger.info '*********************'
      logger.info author.inspect
      logger.info '*********************'
      if author.present?
        @user.author = author[0] if author.present?
        @user.name = author[0].name
        logger.info '* - ********************'
        logger.info @user.inspect
        logger.info '* - ********************'
      else
        @user.build_author name: name
        @user.name = name
      end    
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
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
