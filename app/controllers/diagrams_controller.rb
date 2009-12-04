class DiagramsController < ApplicationController

require 'open3'

  #active_scaffold :diagram

#  before_filter :require_user, {:only => :edit}

#--------------------------------------------------------
  # GET /diagrams
  # GET /diagrams.xml
  def index

    searcher = Diagram.search(:ascend_by_created_at => true)
    if params[:search]
      searcher.authors_name_like params[:search][:authors] if params[:search][:authors] != ''
      searcher.collections_id_equals params[:search][:collections].to_i if params[:search][:collections] != ''
      searcher.stipulation_like params[:search][:stipulation] if params[:search][:stipulation] != ''
    end

    searcher.collections_public_equals true unless current_user
    searcher.user_id_equals current_user.id if current_user

    @diagrams = searcher.paginate :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @diagrams }
    end
  end

#--------------------------------------------------------
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

    render :action => 'edit'
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @diagram }
#    end
  end
#--------------------------------------------------------

# GET /diagrams/1/edit
  def edit
    @diagram = Diagram.find(params[:id])
  end

  # POST /diagrams
  # POST /diagrams.xml
  def create
    @diagram = Diagram.new(params[:diagram])

    respond_to do |format|
      @diagram.user = current_user
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
      @diagram.user = current_user
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
  #--------------------------------------------------
  def section
    @diagram = Diagram.find(params[:id])

    @diagram.sections << Section.find(params[:diagram][:section_ids])

    flash[:notice] = "Diagram was submitted to this competition."

    respond_to do |format|
      format.html { redirect_to(diagrams_url) }
      format.xml  { head :ok }
    end
  end
  #--------------------------------------------------
  def solve
      Open3.popen3  '/usr/local/bin/py' do |input, output, error|
         input.puts <<-EOD
            BeginProblem
            Option NoBoard #{params[:pyopts]}
            Stipulation #{params[:diagram][:stipulation]}
            Pieces
             White #{ nrm(params[:diagram][:white])}
             Black #{ nrm(params[:diagram][:black])}
            #{params[:twin]}
            EndProblem
            EOD
         input.close_write

         @outres = output.gets nil
         @outres.gsub! /^.*\)$/, ''
         @outres.strip!
         @errres = error.gets(nil)
      end
      render :layout => false
  end
###################################################
  private
  def nrm(s)
     return s.split(/[, ]+/).collect do |a|
        a.size < 3 ? 'p' + a : a
     end.join(' ')
  end
###################################################
end
