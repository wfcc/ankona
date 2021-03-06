# coding: utf-8
require 'open3'
require "uri"
require "net/http"

class DiagramsController < NonauthorizedController

  #respond_to_mobile_requests
  #include Mobylette::RespondToMobileRequests

  before_filter :require_user, {:except => [:show]}
  #before_filter :build_pieces, only: :edit


  def index

    params[:q] = {} unless params[:q].present?
    params[:q][:user_id_eq] = current_user.id

    @q = Diagram.search params[:q]
    @diagrams = @q.result.uniq \
      .order {created_at.desc}
      .paginate page: params[:page], per_page: 7
#    @collection_source = current_user \
#        ? Collection.where{user_id == current_user_id} \
#        : Collection.where{public == true}
  end #--------------------------------------------------------

  def show

#    @diagram = Diagram.find_by_id(params[:id])

    respond_to do |format|
      format.html do
        if @diagram
          @shared_with = User.joins{roles}.where{
            (roles.name == 'reader') &
            (roles.resource_id == my{params[:id]}) &
            (roles.resource_type == 'Diagram')
            }
        else
          flash[:error] = 'Diagram not found'
          #redirect_to root_url
        end
      end
      format.png do
        t = @diagram ? @diagram.embedded_diagram(true) : $board
        send_data t, type: 'image/png', disposition: 'inline'
      end
    end


  end #--------------------------------------------------------

  def new
    @diagram = Diagram.new
    @pieces = Piece.all.to_json except: [:id, :created_at, :updated_at, :glyph2, :orthodox]
    if @diagram.pieces['a'].blank?
      @diagram.pieces = Hash.new { |h,k| h[k] = Hash.new { |hh,kk| hh[kk] = '' } }
    end
    render :edit
  end #--------------------------------------------------------

  def edit
    build_pieces true
    ActiveRecord::Base.include_root_in_json = false
    @pieces = Piece.all.to_json except: [:id, :created_at, :updated_at, :glyph2, :orthodox]
    @hideIfFairy = @diagram.fairy.blank? ? 'display:visible' : 'display:none'
    @showIfFairy = @diagram.fairy.blank? ? 'display:none' : 'display:visible'

    @authors_json = @diagram.authors.map{|a| {id: a.id, name: a.name}}.to_json

#    if @diagram.user_id != current_user.id
#      flash[:error] = "You are unauthorized to edit this problem."
#      render :show
#    end
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

    flash[:notice] = "The composition was submitted to this competition."
    render :show
  end #--------------------------------------------------------

  def solve
    x = ''
    params[:pieces].each do |kind,v|
      v.each do |color, pcs|
        next unless pcs.present?
        x += {w: "\n\tWhite", b: "\n\tBlack", n: "\n\tNeutral"}[color.to_sym] + ' '
        x += kind + ' ' unless kind == 'a'
        x += to_english_py(pcs) + ' '
      end
    end
    stip = params[:stipulation].split(' ').shift
    cond = params[:conds].present? ? 'Condition ' + params[:conds] : ''

    input = <<-EOD
    BeginProblem
    Option MaxTime 30 NoBoard #{params[:pyopts]}
    Stipulation #{params[:stipulation]}
    #{cond}
    Pieces #{x}
    #{ twin_to_py params[:twin] }
    EndProblem
    EOD

    unless params['solve'] == 'true'
      render json: {'#solution' => ['text', input]}
    else
      res = Net::HTTP.post_form URI.parse(Settings.popeye_url),
        input: input,
        popeye: Settings.popeye_location
      render json: {'#diagram_solution' => ['text', res.body], '#solve' => ['val', 'Finished. Solve again!']}

    end
  end #--------------------------------------------------------

  def share
    diagram = Diagram.find params[:id]
    my = params[:handle].upcase
    if @u = User.joins{author}.where{author.code == my}.first
      @u.add_role 'reader', diagram
    end
    text = @u.present? ? "Just shared with #{@u.nick}!" : '** No such user found **'
    json = {'#share_results' => ['text', text], '#handle' => ['val', '']}
    respond_to do |format|
      format.js { render json: json, callback: '$.executeObject' }
    end
  end #--------------------------------------------------------

  def clone
    d = Diagram.find params[:id]
    @diagram = d.dup
    @diagram.comment = "Copy of A-#{d.id}.\n\n#{d.comment}"
    #@authors_json = @diagram.authors.map{|a| {id: a.id, name: a.name}}.to_json
    build_pieces false
    #redirect_to new_diagram_path #(@diagram)
    render :edit

  end #--------------------------------------------------------

  private
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  def catch_not_found
#    yield
#  rescue ActiveRecord::RecordNotFound
#    redirect_to root_url, :flash => { :error => "Diagram not found." }
#  end #--------------------------------------------------------

  def to_english_py pieces
    pieces.upcase.split(' ').map do |p|
      p =~ /(..?)(..)/
      (x = Piece.where(code: $~[1]).first) or next p
      x = x.popeye.to_s
      x.size > 0 or next p
      x + $~[2].downcase
    end.join(' ')
  end #--------------------------------------------------------

  def twin_to_py(t)
    s = ''
    word = t.match(/nul|н.ль|zero|зеро/i) ? 'Zero' : 'Twin'
    t.split(/\s?\;?\s?.\)/).each do |x|
      x.split(/,/).each do |y|
        case y
        when /(\w\d).*(↔|<.?.?>).*(\w\d)/
          s += "#{word} Exchange #{$~[1]} #{$~[3]} "
        when /\S*(\w\d)\s*(→|.?.?>).*(\w\d)/
          s += "#{word} Move #{$~[1]} #{$~[3]} "
        when /-.*(\w\d)/
          s += "#{word} Remove #{$~[1]} "
        when /([w|b])(\w\w\d)/i
          s += "#{word} Add #{pieceColor($~[1])} #{$~[2]} "
        else
          next
        end
        word = ''
      end
      word = 'Twin'
    end
    return s
  end #----------------------------------------------------------------

  def pieceColor(color)
    color = color.upcase.to_sym
    {W: 'White', B: 'Black'}[color]
  end #----------------------------------------------------------------

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
  end #----------------------------------------------------------------

  def build_pieces edit

    if edit
      @diagram = Diagram.find(params[:id])
    end
    return unless Diagram.column_names.include? 'pieces'
    return unless @diagram.pieces.blank?

    #swoop = Proc.new { |k, v| v.delete_if(&swoop) if v.kind_of?(Hash);  v.empty? }

    pieces = Hash.new { |h,k| h[k] = Hash.new { |hh,kk| hh[kk] = '' } }
    #pieces = {}
    fen2arr(@diagram.fen).map do |x|
      convert = false
      case x
      when /\[x([A-Z]\w?)\](..)$/
        pieces[:Chameleon][:w]
      when /\[x([a-z]\w?)\](..)$/
        pieces[:Chameleon][:b]
      when /^\(([A-Z]+)\)(..)$/
        pieces['a']['w']
      when /^\(([a-z]+)\)(..)$/
        pieces['a']['b']
      when /^([A-Z]+)(..)$/
        convert = true; pieces['a']['w']
      when /^([a-z]+)(..)$/
        convert = true; pieces['a']['b']
      end << (from_fen_again($~[1].downcase, convert) + $~[2] + ' ')
    end
    @diagram.pieces = pieces
  end #----------------------------------------------------------------

  def from_fen_again x, convert
    return x unless convert
    n = {k: :k, q: :d, r: :t, b: :l, n: :s, p: :p}[x.to_sym].to_s
    n.present? ? n : x # no change
  end #----------------------------------------------------------------

end
