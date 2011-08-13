class FenController < ApplicationController


include Magick

FIGDIR = 'public/images/fig/'
SUFFIX = '.gif'

###########################################################
  def index
    cols, rows = 8, 8
    i, j = -25, 0
    @dia = $board
    prefix = ''

    if params[:id].present?
      slashed = params[:id].split('/')
      slashed.collect! do |rank|
         # replace numbers with spaces
         rank.gsub!(/\d+/) {' ' * $&.to_i}
         rank.ljust(cols) # fill up
      end
      
      pieces = slashed.join.scan(/\[\w+\]|\(\w+\)|./)
      pieces.each do |p|
        (j+=25; i=0) if (i+=25) > 180
        case p
        when ' '
          next
        when /\[x(\w+)\]/
          prefix = 'x'; fig = $~[1]
        else
          prefix = ''; fig = p
        end
        color = fig < 'a' ? 'w' : 'b'
        fig.downcase!
        fig = fig.n2s
        putFigM prefix + color + fig, i, j
      end
    end

    send_data @dia.to_blob, type: 'image/png', disposition: 'inline'
  end
#--------------------------------------------
  private
#--------------------------------------------

  def putFigM(c, i, j)
    logger.info (FIGDIR + c + SUFFIX)
    begin
      fig = Image.read(FIGDIR + c + SUFFIX)[0]
    rescue
      logger.info "bad symbol #{c}"
      pen = Magick::Draw.new
      pen.annotate(@dia, 0,0,0,40, "bad symbol: #{c}") do
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
