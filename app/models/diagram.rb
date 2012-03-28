class Diagram < ActiveRecord::Base

  belongs_to :user
  has_and_belongs_to_many :authors
  has_and_belongs_to_many :collections
  has_and_belongs_to_many :sections
  has_many :publications
  has_many :marks
  has_many :roles, as: :resource

  validates_presence_of :stipulation
  #validates_presence_of :authors
  validates_associated :authors
  before_save :build_pieces
  after_find :build_pieces
  serialize :pieces, Hash


  cattr_reader :per_page
  @@per_page = 20

#  def neutral; self.pieces[:a][:n] end
#  def neutral=(x); self.pieces[:a][:n] = x end

#  def self.serialized_attr_accessor(*args)
#    args.each do |method_name|
#      eval "
#        def #{method_name}
#          (self.pieces || {})[:#{method_name}]
#        end
#        def #{method_name}=(value)
#          self.pieces ||= {}
#          self.pieces[:#{method_name}] = value
#        end
#      "
#    end
#  end  #-------------------------------
 
#  serialized_attr_accessor :a, :chameleon

  def fen
    position
  end  #-------------------------------

  def fen=(p)
    position = p
  end  #-------------------------------

  def kings
    cols = 8
    return '' unless position.present?

    flat = position.split('/').map do |rank|
      # replace numbers with spaces
      rank.gsub!(/\d+/) {' ' * $&.to_i}
      rank.ljust(cols) # fill up
    end.join
    
    %w[K k].map do |k|
      return '?' unless index = flat.index(k)
      octal = sprintf('%02o', index).split ''
      (octal[1].to_i + 97).chr + # 0 -> 'a'
      (8 - octal[0].to_i).to_s # increment 1
    end
  end  #-------------------------------


  def piece_balance
    n = Hash[%w[w b n].zip []]
    if pieces.present?
      pieces.each_pair do |kind, colors|
        colors.each_pair do |color, pieces|
          n[color] = n[color].to_i + pieces.split(/ /).size
        end
      end
      n.values.compact.join '+'
    else
      'empty'
    end
  end  #-------------------------------
  
  def fairy_synopsis
    syn = {}
    if pieces.present?
      pieces.each_pair do |kind, colors|
        hole = kind unless kind == 'a'
        colors.each_pair do |color, pieces|
          pieces.upcase.split(/ /).each do |piece|
            piece.match /^(..?)(..)$/
            next unless $~
            p = Piece.where{code == $~[1]}.first
            if p.blank? or p.name.blank?
              name = 'unknown'
              next
            elsif p.orthodox
              next
            else
              syn[p.name] ||= []
              syn[p.name].push $~[2].downcase
            end
          end
        end
      end
      r = syn.map do |piece, squares|
        piece.capitalize + ' ' + squares.join(', ')
      end.join '; '
      return r
    end
    ''

  end #----------------------------------------------------------------

  def stipulation_classified

    return 'fairy' if fairy.present? && fairy.size

    stipulation.gsub! /\*/, ''
    case stipulation
    when '#2' then '#2'
    when '#3' then '#3'
    when /^s#/ then 's#'
    when 'h#2' then 'h#2'
    when /^#..?/ then '#n'
    when '+', '=' then 'study'
    when /^h#[2.5|3]\*?/ then 'h#3'
    when /^h/ then 'h#n'
    else 'retro'
    end
  end #----------------------------------------------------------------

  def embedded_diagram
    cols, rows = 8, 8
    i, j = -25, 0
    @dia = $board

    if pieces.present?
#logger.warn '****>>>'
#logger.warn pieces.inspect
#logger.warn '****<<<'      
      pieces.each_pair do |kind, colors|
#logger.warn '****>'
#logger.warn colors.inspect
#logger.warn '****<'      
        colors.each_pair do |color, pieces|
          pieces.downcase.split(/ /).each do |piece|
            m = piece.match /(..?)(.)(.)/
            next unless m
            fig = m[1]
            fig = Piece.where{code == fig.upcase}.first.et.glyph1
            y = (49 + 7 - m[3].ord) * 25
            x = (m[2].ord - 97) * 25
            prefix = kind == 'a' ? '' : 'x'
            s = fig.present? ? prefix + color.to_s + fig.downcase : 'magic'
            putFigM s, x, y
          end
        end
      end
    elsif position.present?
      slashed = position.split('/')
      slashed.collect! do |rank|
         # replace numbers with spaces
         rank.gsub!(/\d+/) {' ' * $&.to_i}
         rank.ljust(cols) # fill up
      end
      
      pieces = slashed.join.scan(/\[\w+\]|\(\w+\)|./)
      pieces.each do |p|
        prefix = ''
        fig = p
        (j+=25; i=0) if (i+=25) > 180
        case p
        when ' '
          next
        when /\[x(\w+)\]/
          prefix = 'x'; fig = $~[1]
        when /\((\w+)\)/
          fig = $~[1]
          fig = Piece.where{code == fig.upcase}.first.et.glyph1
        end
        color = p.match(/^(\(|\[.)?[A-Z]/) ? 'w' : 'b'
        if fig.present?
          putFigM prefix + color + fig.downcase, i, j
        else
          putFigM 'magic', i, j
        end
      end
    end

    'data:image/png;base64,' + Base64.encode64(@dia.to_blob)
    
  end #----------------------------------------------------------------
  def afen
#    x = PieceBlock.new
#    pieces.each_pair do |kind, colors|
#      colors.each_pair do |color, pieces|
#        pieces.split(/ /).each do |piece|
#          if color == 'w'
#            x.pieces[0].push



  end #----------------------------------------------------------------

  private

  def putFigM(c, i, j)
    c.sub! /s/, 'n' # can't avoid it!
    fig = $figurines[c] || $figurines['magic']
    @dia = @dia.composite(fig, i+1, j+1, Magick::OverCompositeOp)
  end  #-------------------------------

  def build_pieces

    return unless Diagram.column_names.include? 'pieces'
    return unless pieces.blank?

    swoop = Proc.new { |k, v| v.delete_if(&swoop) if v.kind_of?(Hash);  v.empty? }
    if position != ''

      self.pieces = Hash.new { |h,k| h[k] = Hash.new { |hh,kk| hh[kk] = '' } }
      fen2arr(fen).map do |x|                   
        case x
        when /\[x([A-Z]\w?)\](..)$/
          pieces[:Chameleon][:w]
        when /\[x([a-z]\w?)\](..)$/
          pieces[:Chameleon][:b]
        when /^\(?([A-Z]+)\)?(..)$/
          pieces['a']['w']
        when /^\(?([a-z]+)\)?(..)$/
          pieces['a']['b']
        #end.push $~[1].downcase + $~[2]
        end << (from_fen_again($~[1].downcase) + $~[2] + ' ')
      end
      self.position = ''
    else
      self.pieces.delete_if &swoop
    end
  end  #-------------------------------
  def from_fen_again x
    n = {k: :k, q: :d, r: :t, b: :l, n: :s, p: :p}[x.to_sym].to_s
    n.present? ? n : x # no change
  end  #-------------------------------

end
