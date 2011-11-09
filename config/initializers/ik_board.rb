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
    a = fen
      .gsub(/(?!\()n(?!\))/, 's') \
      .gsub(/(?!\()N(?!\))/, 'S') \
      .gsub(/\d+/){'1' * $&.to_i} \
      .scan(/\(\w+\)|\[.\w+\]|\w/)

    a.select_with_index do |x,i|
      next if x == '1'
      b.push x + index2algebraic(i)
    end
    return b
  end

  def array_to_popeye(a)
    w = []; b = []; wc = []; bc = []
    a.map do |x|                   
      case x
      when /\[x([A-Z]\w?)\](..)$/
        wc
      when /\[x([a-z]\w?)\](..)$/
        bc
      when /^\(?([A-Z]+)\)?(..)$/
        w
      when /^\(?([a-z]+)\)?(..)$/
        b
      end.push $~[1] + $~[2]
    end
      
      w.join(' ').predifix(' White ') +
      b.join(' ').predifix(' Black ') +
      wc.join(' ').predifix(' White Chameleon ') +
      bc.join(' ').predifix(' Black Chameleon ')
  end

  def fairy_synopsis(a)
    bc = []; wc = []; fp = {}
    a.each do |piece|
      case piece
      when /\[x([a-z]+)\](..)/
        bc.push $~[1].upcase + $~[2]
      when /\[x([A-Z]+)\](..)/
        wc.push $~[1] + $~[2]
      when /\(([A-Z]+)\)(..)/i
        name = Piece.where{code == $~[1].upcase}.first.et.name
        name = 'unknown' if name.blank?
        fp[name] ||= []
        fp[name].push $~[2]
      end
    end
    chameleons = (wc + bc).join(', ').predifix('Chameleon ')
    fp.map{|k,v| k.capitalize + ' ' + v.join(',') }.push(chameleons).join('; ')
  end
                     
