include Magick

  $board = Image.read('app/assets/images/fig/board.png')[0]

  def create_board # this is never called.  Use to recreate board.png
    cols, rows = 8, 8
    flip = rows % 2

    canvas = Image.new(cols*25+2, rows*25+2) do
      self.background_color = "#FFFFF0"
    end
    canvas.border!(1, 1, 'black')
    rows.times do |x|
      cols.times do |y|
        pen = Magick::Draw.new
        pen.fill = (flip ^ y%2 ^ x%2 > 0) ? '#C8C8B6' : '#FFFFF0'
        pen.rectangle x*25+1,y*25+1,x*25+25+2,y*25+25+2
        pen.draw(canvas)
      end
    end
    canvas.format = 'PNG'
    canvas.write('board.png')
  end
              
  def index2algebraic(x)
    sprintf('%02o', x) =~ /(.)(.)/
    ($~[2].ord + 49).chr + (8 - $~[1].to_i).to_s
  end

  def fen2arr(fen)                                        
    b = []
    a = fen.gsub(/\d+/){'1' * $&.to_i}.scan(/\[.\w+\]|\w/)
    a.select_with_index do |x,i|
      next if x == '1'
      x = x.n2s
      b.push x + index2algebraic(i)
    end
    return b
  end

  def array_to_popeye(a)
    w = []; b = []; wc = []; bc = []
    a.map do |x|                   
      case x
      when /\[x([A-Z]\w?)\](..)$/
        wc.push $~[1].n2s + $~[2]
      when /\[x([a-z]\w?)\](..)$/
        bc.push $~[1].n2s + $~[2]
      when /^[A-Z]..$/
        w.push $&
      when /^[a-z]..$/
        b.push $&
      end
    end
      
      w.join(' ').predifix(' White ') +
      b.join(' ').predifix(' Black ') +
      wc.join(' ').predifix(' White Chameleon ') +
      bc.join(' ').predifix(' Black Chameleon ')
  end

  def fairy_synopsis(a)
    bc = []; wc = []
    a.each do |piece|
      case piece
      when /\[x([a-z]+)\](..)/
        bc.push $~[1].upcase + $~[2]
      when /\[x([A-Z]+)\](..)/
        wc.push $~[1] + $~[2]
      end
    end
    return [wc.join(', ').predifix('White Chameleons: '),
      bc.join(', ').predifix('Black Chameleons: ')].join '; '
  end
                     
