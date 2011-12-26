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
#  after_update :save_authors

  cattr_reader :per_page
  @@per_page = 20
  #-------------------------------
  
  def save_authors
    authors.each do |author|
      author.save false
    end
  end #----------------------------------------------------------------

  def existing_author_attributes=(author_attributes)
    authors.reject(&:new_record?).each do |author|
      attributes = author_attributes[author.id.to_s]
      if attributes
        author.attributes = attributes
      else
        authors.delete(author)
      end
    end
  end #----------------------------------------------------------------

  def new_author_attributes=(author_attributes)
    author_attributes.each do |attributes|
      authors.build(attributes)
    end
  end #----------------------------------------------------------------

  def fen
    position
  end #----------------------------------------------------------------

  def fen=(p)
    position = p
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
      
  end #----------------------------------------------------------------

  def fen2arr 
    b = []
    a = position
      .gsub(/(?!\()n(?!\))/, 's') \
      .gsub(/(?!\()N(?!\))/, 'S') \
      .gsub(/\d+/){'1' * $&.to_i} \
      .scan(/\(\w+\)|\[.\w+\]|\w/)

    a.select_with_index do |x,i|
      next if x == '1'
      b.push x + index2algebraic(i)
    end
    return b
  end #----------------------------------------------------------------

  def piece_balance
    w = b = n = 0
    fen2arr.each do |piece|
      case piece
      when /^(\[.)?\(?[[:upper:]]/
        w = w + 1
      when /^(\[.)?\(?[[:lower:]]/
        b = b + 1
      end
    end
    "#{w}+#{b}"
  end #----------------------------------------------------------------
  
  def fairy_synopsis
    return '' unless position.match /\[|\(/
    bc = []; wc = []; fp = {}
    fen2arr.each do |piece|
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
    chameleons = (wc + bc).commatize.predifix('Chameleon ')
    fp.map{|k,v| k.capitalize + ' ' + v.join(',') }.push(chameleons).semicolonize
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

end
