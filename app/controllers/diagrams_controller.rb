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
    @hideIfFairy = @diagram.fairy.blank? ? 'display:visible' : 'display:none'
    @showIfFairy = @diagram.fairy.blank? ? 'display:none' : 'display:visible'
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
      condition = params[:pyconds].blank? ? '' : "Condition #{params[:pyconds]}"
       stdin = <<-EOD
            BeginProblem
            Option NoBoard #{params[:pyopts]}
            Option MaxTime 120             
            Stipulation #{params[:diagram][:stipulation]}
            #{condition}
            Pieces
             White #{ nrm(params[:diagram][:white])}
             Black #{ nrm(params[:diagram][:black])}
            #{twin_to_py params[:diagram][:twin]}
            EndProblem
            EOD
      logger.info "<<stdin<< #{stdin} >>stdin>>"
      res = Net::HTTP.post_form(URI.parse('http://util.dia-x.info/popeye/solve'),
           {:pyinput => stdin})

      logger.info "<<< #{res.body} >>>"
      render :text => res.body
  end
###################################################
  private
  def nrm(s)
    return s.split(/[, ]+/).collect do |a|
      (a.size < 3 ? 'P' + a : a).capitalize.tr 'DTL', 'QRB' # FIDE -> English
    end.join(' ')
  end

  def twin_to_py(t)
    s = t
    logger.info "==<<== #{t} ==>>=="
    case t
    when nil, '', /^\d/ then s = ''
    when /(\S+)\s*(↔|<.?.?>)\s*(\S+)/
      s = "Twin Exchange #{$~[1][-2,2]} #{$~[3][-2,2]}"
    when /(\S+)\s*(→|.?.?>)\s*(\S+)/
      s = "Twin Move #{$~[1][-2,2]} #{$~[3][-2,2]}"
    end
    return s
  end

###################################################
end
