class VersionsController < ApplicationController
  def create
    @diagram = Diagram.find params[:diagram_id]
    @diagram.versions.build fef: @diagram.afen, description: params[:description]
    @diagram.save
    render js: {aaa: 333}
  end
end
