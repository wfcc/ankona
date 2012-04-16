class VersionsController < ApplicationController

  respond_to :js
  before_filter :find_diagram, only: [:destroy, :index, :create]
  layout false
  
  def index
    @versions = @diagram.versions
    render json: find_versions
  end

  def create
    d = Diagram.new pieces: params[:pieces]
    if @diagram.afen == d.afen
      @error = 'Position is the same, not saving version.'
    else
      @error = nil
      @diagram.versions.create fef: d.afen, description: params[:description]
      find_versions
    end

    respond_with @versions do |format|
      format.js { render action: 'table' }
    end
  end

  def destroy
    @version = Version.find_by_id params[:id]
    @version.destroy
    find_versions
    render 'table'
  end

  def show
    @version = Version.find_by_id params[:id]
    d = Diagram.new
    @pieces = d.deafen(@version.fef).to_json.html_safe
  end
  
  private # -----------------------------------------------------------------

  def find_diagram
    @diagram = Diagram.find_by_id params[:diagram_id]
  end

  def find_versions
    @versions = @diagram.versions.to_json(methods: :fef5, only: [:fef5, :description, :id]).html_safe
  end
end
