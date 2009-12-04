class Author < ActiveRecord::Base
  has_and_belongs_to_many :diagrams

  validates_presence_of :name

protected
#  def validate
#    errors.add_on_empty %w( birth_date ), 'No birth date'
#  end

end
