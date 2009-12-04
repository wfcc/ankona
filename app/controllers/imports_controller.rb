class ImportsController < ApplicationController
  def index
    @import = Import.new
  end

  def update
    @import = Import.new(params[:import])
    respond_to do |format|
      if @import.valid?
        @@converter = Iconv.new 'utf8', 'cp1250'
        case @import.format
        when 'CCV'
          pieces = %w[1 P p R r S s B b Q q K k *]
          counter, number = 0, 0
          logger.info @import.inspect
          while (line = @import.uploaded_file.gets)
            line.chomp!
logger.info "[- #{line} -]"
            case
            when line =~ /^Dg.*=new Array/
              d = Diagram.new(:user => current_user)
              d.save false
              black, white, number, author = '', '', 0, ''
              logger.info '>> New Array'
            when line.empty?
               next if author.empty?
               d.white, d.black = white, black
               d.collections << Collection.find(@import.collection)
               author.split(/\s*,\s*/).each do |x|
                 d.authors << Author.find_or_create_by_name(x)
               end
               logger.info ">> black: #{black} white: #{white} author: #{author}"
               logger.info '|====> ' + d.inspect
               d.save false
               counter += 1
            when number <= 8
               f = line.split(/\D+/)
               f.shift
               logger.info '>> pieces: ' + f.inspect
               f.each_with_index do |piece, vertical|
                  next if piece == '0'
                  p = pieces[piece.to_i].upcase
                  t = "#{p}#{(vertical+97).chr}#{9-number}"
                  if piece.to_i % 2 > 0
                    white += t + ' '
                  else
                    black += t + ' '
                  end
               end
            when number == 9
              author = @@converter.iconv line[2..-4]
            when number == 10
              d.source = @@converter.iconv(line[2..-4])
            when number == 11
              d.solution = line[2..-4]
              d.solution.gsub! /\\n/, "\n"
            when number == 12
              d.stipulation = line[2..-5]
            end
            number = number.next
          end
          flash[:notice] = "#{counter} diagrams imported from a CCV file into '#{@import.collection}' collection."
        end
        # format.html { redirect_to(@import) }
        format.html { redirect_to :action => 'index' }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
#        flash[:error] = 'Import failed'
        logger.info @import.errors.inspect
        format.html { render :action => "index" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end

#    a = ''
#    counter = 0
#    while (line = params[:file][:uploaded_file].gets)
#        a = a +  "#{counter} #{line}"
#    end
#    render :=> a
  end

  def upload_action
    # Do stuff with params[:uploaded_file]
    responds_to_parent do
      render :update do |page|
        page.replace_html 'upload_form', :partial => 'upload_form'
      end
    end
  end
end
