include Magick

  $board = Image.read('public/images/fig/board.png')[0]

  def create_board
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

