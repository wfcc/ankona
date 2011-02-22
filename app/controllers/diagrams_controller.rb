# coding: utf-8
class DiagramsController < ApplicationController

require 'open3'

  #active_scaffold :diagram

  before_filter :require_user, {:except => [:index, :show]}

#--------------------------------------------------------
  # GET /diagrams
  # GET /diagrams.xml
  def former_index

    searcher = Diagram.order(:created_at.asc)
    if params[:search].present?
      searcher = searcher.where(:stipulation[params[:search][:stipulation]])
   end

    #searcher.collections_public_equals true unless current_user
    #searcher.user_id_equals current_user.id if current_user

    @diagrams = searcher.paginate :page => params[:page]

  end
# ===========================================================================
  def mine
    
    @diagrams = Diagram
      .where(:user_id.eq => current_user.id)
      .paginate(page: params[:page])
      
    render :index
  end

#----- GET /diagrams/1 ------------------------------------------------------
  def show
    @diagram = Diagram.find(params[:id])
  end

#----- GET /diagrams/new ----------------------------------------------------
  def new
    @diagram = Diagram.new
    render :edit
  end

#----- GET /diagrams/1/edit ----------------------------------------------
  def edit
    @diagram = Diagram.find(params[:id])
    @hideIfFairy = @diagram.fairy.blank? ? 'display:visible' : 'display:none'
    @showIfFairy = @diagram.fairy.blank? ? 'display:none' : 'display:visible'
    
    @authors_json = @diagram.authors.map{|a| {id: a.id, name: a.name}}.to_json
    
    if @diagram.user_id != current_user.id
      flash[:error] = "You are unauthorized to edit this problem."
      render :show
    end
  end
#----- POST /diagrams -----------------------------------------------------
  def create
    @diagram = Diagram.new(params[:diagram])
    save_diagram true
  end
#----- PUT /diagrams/1 -----------------------------------------------------
  def update
    @diagram = Diagram.find(params[:id])
    @diagram.authors = Author.find params[:authors_ids].split(',')
    if @diagram.update_attributes(params[:diagram])
      flash[:notice] = "Successfully updated problem."
      render :show
    else
      flash[:error] = "Errors saving problem."
      render :edit
    end
  end
#----- DELETE /diagrams/1 --------------------------------------------------
  def destroy
    @diagram = Diagram.find(params[:id])
    @diagram.destroy

    redirect_to(diagrams_url)
  end
  #--------------------------------------------------
  def section
    @diagram = Diagram.find(params[:id])

    @diagram.sections << Section.find(params[:diagram][:section_ids])

    flash[:notice] = "Diagram was submitted to this competition."
    render :show
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
###################################################
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
  def save_diagram(is_create)
    respond_to do |format|
      @diagram.user = current_user
      @diagram.authors = Author.find params[:authors_ids].split(',')
      if @diagram.save
        flash[:notice] = 'Problem was successfully saved.'
        redirect_to(@diagram)
      else
        flash[:error] = 'Problem was not saved due to errors.'
        render :edit
      end
    end
  end
###################################################
end
