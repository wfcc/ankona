class DiagramsController < ApplicationController

  active_scaffold :diagram

  # GET /diagrams
  # GET /diagrams.xml
  def index
    @diagrams = Diagram.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @diagrams }
    end
  end

  # GET /diagrams/1
  # GET /diagrams/1.xml
  def show
    @diagram = Diagram.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @diagram }
    end
  end

  # GET /diagrams/new
  # GET /diagrams/new.xml
  def new
    @diagram = Diagram.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @diagram }
    end
  end

  # GET /diagrams/1/edit
  def edit
    @diagram = Diagram.find(params[:id])
  end

  # POST /diagrams
  # POST /diagrams.xml
  def create
    @diagram = Diagram.new(params[:diagram])

    respond_to do |format|
      if @diagram.save
        flash[:notice] = 'Diagram was successfully created.'
        format.html { redirect_to(@diagram) }
        format.xml  { render :xml => @diagram, :status => :created, :location => @diagram }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @diagram.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /diagrams/1
  # PUT /diagrams/1.xml
  def update
    @diagram = Diagram.find(params[:id])

    respond_to do |format|
      if @diagram.update_attributes(params[:diagram])
        flash[:notice] = 'Diagram was successfully updated.'
        format.html { redirect_to(@diagram) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @diagram.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /diagrams/1
  # DELETE /diagrams/1.xml
  def destroy
    @diagram = Diagram.find(params[:id])
    @diagram.destroy

    respond_to do |format|
      format.html { redirect_to(diagrams_url) }
      format.xml  { head :ok }
    end
  end
end
