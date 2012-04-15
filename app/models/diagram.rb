class NilClass; def glyph1; nil end end

class Diagram < ActiveRecord::Base

  belongs_to :user
  has_and_belongs_to_many :authors
  has_and_belongs_to_many :collections
  has_and_belongs_to_many :sections
  has_many :publications
  has_many :marks
  has_many :roles, as: :resource
  has_many :versions

  validates_presence_of :stipulation
  #validates_presence_of :authors
  validates_associated :authors
  serialize :pieces, Hash
  accepts_nested_attributes_for :versions

  cattr_reader :per_page
  @@per_page = 20

  @@wbn = {w: 0, b: 1, n: 2}
  @@fef_pieces = %w[K D T L S P]


  def fen; position end  #-------------------------------

  def fen=(p); position = p end  #-------------------------------

  def afen
    '*' + afen_struct.to_binary_s.unpack('H*')[0].to_i(16).base62_encode
  end #----------------------------------------------------------------

  def afen_struct
    x = PieceBlock.new
    pieces.each_pair do |variety, colors|
      colors.each_pair do |color, pieces|
        pieces.split(/ /).each do |piece|
          piece =~ /^(?<piece>..?)(?<file>.)(?<rank>.)$/
          coords = {xy: [
              $~[:file].downcase.ord - 97,
              $~[:rank].downcase.ord - 49]}
          if piece = piece3bit($~[:piece]) and variety == 'a'
            piecespec = {kind: piece, piece: coords}
          else
            piecespec = {kind: 0b111, piece: coords.merge({fairy_piece: encode_fp($~[:piece], variety)})}
          end
          x.wbn[color3bit(color)].push piecespec
        end
      end
    end
    x.wbn.each{|y| y.push kind: 0b110} # stop codon
    fef = FefBlock.new
    fef.version = Settings.fef_version
    fef.piece_block = x
    fef
  end #----------------------------------------------------------------
  def deafen a=afen
    a.gsub! /^\*/, ''
    fef = FefBlock.new
    s16 = a.base62_decode.to_s(16)
    s16 = '0' + s16 if s16.size & 1 # pad if odd
    fef.read [s16].pack('H*')

    pieces = Hash.new { |h,k| h[k] = Hash.new { |hh,kk| hh[kk] = '' } }
    @@wbn.each_pair do |color, n|
      fef['piece_block']['wbn'][n].each do |c|
        next if c['kind'] == 6
        next if c['kind'] == 7
        k = @@fef_pieces[c['kind']]
        x = (c['piece']['xy'][0].to_i + 97).chr
        y = c['piece']['xy'][1].to_i + 1
        pieces['a'][color.to_s] += "#{k}#{x}#{y} "
      end
    end
    pieces

  end #----------------------------------------------------------------

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
    n = {}
    if pieces.present?
      pieces.each_pair do |kind, colors|
        colors.each_pair do |color, pieces|
          n[color] = n[color].to_i + pieces.split(/ /).size
        end
      end
      n.values.reject{|x|x==0}.join '+'
    else
      a = fen2arr fen
      [a.select{|x| x.match /[[:upper:]][\W]?\w\w$/}.size,
      a.select{|x| x.match /[[:lower:]][\W]?\w\w$/}.size].join '+'
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
      pieces.each_pair do |kind, colors|
        colors.each_pair do |color, pieces|
          pieces.downcase.split(/ /).each do |piece|
            m = piece.match /(..?)(.)(.)/
            next unless m
            fig = m[1]
            #fig = Piece.where{code == fig.upcase}.first.et.glyph1
            fig = Piece.find_by_code(fig.upcase).glyph1
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
          fig = Piece.find_by_code(fig.upcase).glyph1
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

  private

  def putFigM(c, i, j)
    c.sub! /s/, 'n' # can't avoid it!
    fig = $figurines[c] || $figurines['magic']
    @dia = @dia.composite(fig, i+1, j+1, Magick::OverCompositeOp)
  end  #-------------------------------

  def piece3bit p
    {k: 0, d: 1, t: 2, l: 3, s: 4, p: 5}[p.downcase.to_sym]
  end  #-------------------------------

  def color3bit p
    @@wbn[p.downcase.to_sym]
  end  #-------------------------------

  def encode_fp p, variety
    p = p.downcase.ljust(2)
    x = FairyPiece.new
    x.letter1 = p[0].ord
    x.letter2 = p[1].ord
    if variety != 'a'
      x.not_a = 1
      x.variety = Settings.fairy_variant.index(variety)
    else
      x.not_a = 0
    end
    x
  end  #-------------------------------

end
