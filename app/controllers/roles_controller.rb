class RolesController < ApplicationController

  before_filter :require_admin
  
  def index
    @roles = Role.all
  end

  def show
    @role = Role.find(params[:id])
  end

  def new
    @role = Role.new
  end

  def edit() @role = Role.find(params[:id]) end

  def create
    @role = Role.new(params[:role])

    if @role.save
      flash[:notice] = 'Role was successfully created.'
      redirect_to(@role)
    else
      render :new
    end
  end

  def update
    @role = Role.find(params[:id])

    if @role.update_attributes(params[:role])
      flash[:notice] = 'Role was successfully updated.'
      redirect_to(@role)
    else
      render :edit
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
  end
end
