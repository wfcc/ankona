# coding: utf-8
class DiagramsController < AuthorizedController

require 'open3'
require "uri"
require "net/http"

  before_filter :require_user, {:except => [:index, :show]}

  def index

    params[:q] = {} unless params[:q].present?
    params[:q][:user_id_eq] = current_user.id

    @q = Diagram.search params[:q]
    @diagrams = @q.result \
      .order {created_at.desc}
      .paginate page: params[:page], per_page: 7
#    @collection_source = current_user \
#        ? Collection.where{user_id == current_user_id} \
#        : Collection.where{public == true}
  end #--------------------------------------------------------

  def show
    @diagram = Diagram.find(params[:id])
    @shared_with = User.joins{roles}.where{
      (roles.name == 'reader') &
      (roles.resource_id == my{params[:id]}) &
      (roles.resource_type == 'Diagram')
      }

  end #--------------------------------------------------------

  def new
    @diagram = Diagram.new
    render :edit
  end #--------------------------------------------------------

  def edit
    ActiveRecord::Base.include_root_in_json = false
    @pieces = Piece.all.to_json except: [:id, :created_at, :updated_at]
    @diagram = Diagram.find(params[:id])
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
    input = <<-EOD
    BeginProblem
    Option NoBoard #{params[:pyopts]}
    Option MaxTime 30
    Stipulation #{params[:stipulation]}
    Pieces #{array_to_popeye(fen2arr(params[:position]))}
    #{ twin_to_py params[:twin] }
    EndProblem
    EOD
    res = Net::HTTP.post_form URI.parse(Ya['popeye_url']),
      input: input,
      popeye: Ya['popeye_location']

    render text: res.body
  end #--------------------------------------------------------

  def share
    diagram = Diagram.find params[:id]
    my = params[:handle].upcase
    if @u = User.joins{author}.where{author.code == my}.first
      @u.has_role 'reader', diagram
    end
  end #--------------------------------------------------------

  private
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def fen2arr(position)
    b = []
    a = position
      .gsub(/(?!\()n(?!\))/, 's') \
      .gsub(/(?!\()N(?!\))/, 'S') \
      .gsub(/\d+/){'1' * $&.to_i} \
      .scan(/\(\w+\)|\[.\w+\]|\w/)

    a.select_with_index do |x,i|
      next if x == '1'
      b.push x + index2algebraic(i)
    end
    return b
  end #----------------------------------------------------------------

  def twin_to_py(t)
    s = ''
    logger.warn " #{t} "
    word = t.match(/zero|nulinė/i) ? 'Zero' : 'Twin'
    t.split(/\s?\;?\s?.\)/).each do |x|
      case x
      #when nil, '', /^\d/ then s = ''
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
      word = 'Twin'
    end
    logger.warn "==<<== #{s} ==>>=="
    return s
  end
###################################################
  def pieceColor(color)
    color = color.upcase.to_sym
    {W: 'White', B: 'Black'}[color]
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
