class FenController < ApplicationController

   require 'gd2'
   include GD2

FIGDIR = 'public/images/fig/'
SUFFIX = '.gif'

   def index
      cols, rows = 8, 8
      flip = rows % 2
      board = Image::IndexedColor.new cols*25+2, rows*25+2
      white = board.palette.resolve Color[1.0, 1.0, 0.94]
      black = board.palette.resolve Color[0.78,0.78,0.71]
      @red  = board.palette.resolve Color[0.78,0.12,0.12]
      board.draw do |pen|
         pen.color = board.palette.resolve Color::BLACK
         pen.fill
         rows.times do |x|
            cols.times do |y|
               pen.color = flip ^ y%2 ^ x%2 > 0 ? black : white
               pen.rectangle x*25+1,y*25+1,x*25+25,y*25+25,true
            end
         end
      end
      # board done

      @fig = {}
      params[:id].collect! do |rank|
         # replace numbers with spaces
         rank.gsub!(/\d/) {' ' * $&.to_i}
         rank.ljust(cols) # fill up
      end
      i, j = 0, 0
      params[:id].to_s.each_byte do |c|
         unless c == 32
            c = c.chr
            c < 'a' ? c.downcase! : c = 'b' + c
            c.sub! /n/, 's'
            putFig board, c, i, j
         end
         (j+=25; i=0) if (i+=25) > 180
      end
      render :text => board.png, :content_type => 'image/png'
   end
###################################################
   private
###################################################
   def putFig(board, c, i, j)
      begin
         @fig[c] = Image.import FIGDIR + c + SUFFIX unless @fig[c]
      rescue
         board.draw do |pen|
            pen.color = @red
            pen.move_to 25, 180
            pen.font = Font::TrueType[
               '/usr/share/fonts/truetype/msttcorefonts/times.ttf', 20]
            pen.text "bad symbol '#{c}'"
         end
      else
         board.merge_from @fig[c], i+1, j+1, 0,0,25,25,1
      end
   end
  end
