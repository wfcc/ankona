# coding: utf-8
class DiagramsController < AuthorizedController

require 'open3'
require "uri"
require "net/http"

  before_filter :require_user, {:except => [:index, :show]}

  def index

    current_user_id = current_user.id
    @diagrams = Diagram.search(params[:search])
      .where {user_id == current_user_id} 
      .order {created_at.desc} 
      .paginate page: params[:page], per_page: 7
    @collection_source = current_user \
        ? Collection.where{user_id == current_user_id} \
        : Collection.where{public == true}
  end #--------------------------------------------------------

  def show
    @diagram = Diagram.find(params[:id])
  end #--------------------------------------------------------

  def new
    @diagram = Diagram.new
    render :edit
  end #--------------------------------------------------------

  def edit
    @diagram = Diagram.find(params[:id])
    @hideIfFairy = @diagram.fairy.blank? ? 'display:visible' : 'display:none'
    @showIfFairy = @diagram.fairy.blank? ? 'display:none' : 'display:visible'
    
    @authors_json = @diagram.authors.map{|a| {id: a.id, name: a.name}}.to_json
    
    if @diagram.user_id != current_user.id
      flash[:error] = "You are unauthorized to edit this problem."
      render :show
    end
  end #--------------------------------------------------------

  def create
    @diagram = Diagram.new(params[:diagram])
    save_diagram true
  end #--------------------------------------------------------

  def update
    @diagram = Diagram.find(params[:id])
    @diagram.update_attributes(params[:diagram])
    save_diagram false
  end #--------------------------------------------------------

  def destroy
    @diagram = Diagram.find(params[:id])
    @diagram.destroy

    redirect_to(diagrams_url)
  end #--------------------------------------------------------

  def section
    @diagram = Diagram.find(params[:id])

    @diagram.sections << Section.find(params[:diagram][:section_ids])

    flash[:notice] = "Diagram was submitted to this competition."
    render :show
  end #--------------------------------------------------------

  def solve

    input = <<-EOD
    BeginProblem
    Option NoBoard #{params[:pyopts]}
    Option MaxTime 30             
    Stipulation #{params[:stipulation]}
    Pieces #{array_to_popeye(fen2arr(params[:position]))}
    EndProblem
    EOD

    res = Net::HTTP.post_form URI.parse(Ya['popeye_url']), 
      input: input,
      popeye: Ya['popeye_location']

    render text: res.body
  end
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

    if @diagram.authors.blank? and params[:authors_ids].blank?
      flash[:error] = 'Author(s) required.'
      render :edit
      return
    end
    @diagram.user = current_user
    if params[:authors_ids].present?
      @diagram.authors = params[:authors_ids].split(',').map do |x|
        if x =~ /^CREATE_(.+)$/
          Author.create name: $1
        else
          Author.find x
        end
      end
    end

    if @diagram.save
      flash[:notice] = 'Problem was successfully saved.'
      redirect_to(@diagram)
    else
      flash[:error] = 'Problem was not saved due to errors.'
      render :edit
    end
  end
###################################################
end
