class FenController < ApplicationController


include Magick

FIGDIR = 'app/assets/images/fig/'
SUFFIX = '.gif'

###########################################################
  def index
    cols, rows = 8, 8
    i, j = -25, 0
    @dia = $board

    if params[:id].present?
      slashed = params[:id].split('/')
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

    send_data @dia.to_blob, type: 'image/png', disposition: 'inline'
  end
#--------------------------------------------
  private
#--------------------------------------------

  def putFigM(c, i, j)
    #c = 'magic' unless File.readable?(FIGDIR + c + SUFFIX)
    begin
      fig = $figurines[c] or $figurines['magic']
      #fig = Image.read(FIGDIR + c + SUFFIX)[0]
    rescue
      logger.warn "bad: #{c}"
      pen = Magick::Draw.new
      pen.annotate(@dia, 0,0,0,40, "bad: #{c}") do
        self.font_family = 'Georgia'
        self.fill = '#FF5353'
        self.stroke = 'transparent'
        self.pointsize = 24
        self.font_weight = BoldWeight
        self.gravity = SouthGravity
      end
    else
      @dia = @dia.composite(fig, i+1, j+1, Magick::OverCompositeOp)
    end
  end
###########################################################
end
