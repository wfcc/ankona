class Diagram < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :authors
  has_and_belongs_to_many :collections
  has_and_belongs_to_many :sections
  has_many :publications

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
  end

  def existing_author_attributes=(author_attributes)
    authors.reject(&:new_record?).each do |author|
      attributes = author_attributes[author.id.to_s]
      if attributes
        author.attributes = attributes
      else
        authors.delete(author)
      end
    end
  end

  def new_author_attributes=(author_attributes)
    author_attributes.each do |attributes|
      authors.build(attributes)
    end
  end
  def fen
    position
  end
  def fen=(p)
    position = p
  end
end
