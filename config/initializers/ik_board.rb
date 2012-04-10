class ChessBoard

  include Magick
  attr_accessor :fig_path

  def initialize path
    @fig_path = path
  end

  def board
    Image.read(@fig_path + 'board.png')[0]
  end

  def figs
    figurines = {}

    %w[k q r b n p].each do |kind|
      %w[w b n].each do |color|
        ['', 'w', 'o', 'z'].each do |orientation|
          ['', 'x'].each do |box|
            name = box + color + kind + orientation
            figurines[name] = Image.read("#{@fig_path}#{name}.gif")[0]
          end
        end
      end
    end
    %w[magic].each do |name|
      figurines[name] = Image.read("#{@fig_path}#{name}.gif")[0]
    end
    figurines
  end

  def create_board # this is never called.  Use to recreate board.png
    cols, rows = 8, 8
    flip = rows % 2

    canvas = Image.new(cols*25, rows*25) do
      self.background_color = "#FFFFF0"
    end
    rows.times do |x|
      cols.times do |y|
        pen = Magick::Draw.new
        pen.fill = (flip ^ y%2 ^ x%2 > 0) ? '#C8C8B6' : '#FFFFF0'
        pen.rectangle x*25,y*25,x*25+25,y*25+25
        pen.draw(canvas)
      end
    end
    canvas.border!(1, 1, '#666')
    canvas.format = 'PNG'
    canvas.write("#{@fig_path}board.png")
  end
end #================================================================

cb = ChessBoard.new 'app/assets/images/fig/'
$board = cb.board
$figurines = cb.figs

def index2algebraic x 
  sprintf('%02o', x) =~ /(.)(.)/
  ($~[2].ord + 49).chr + (8 - $~[1].to_i).to_s
end #----------------------------------------------------------------

def fen2arr position
  position ||= ''
  b = []
  a = position
    .gsub(/\d+/){'1' * $&.to_i} \
    .scan(/\(\w+\)|\[.\w+\]|\w/)

  a.select_with_index do |x,i|
    next if x == '1'
    b.push x + index2algebraic(i)
  end
  return b
end #----------------------------------------------------------------

def popeyze a
  p = Piece.where(code: a.upcase).first
  p.blank? || p.popeye.blank? ? a : p.popeye
end