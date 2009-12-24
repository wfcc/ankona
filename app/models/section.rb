class Section < ActiveRecord::Base
  belongs_to :competition
  belongs_to :user
  has_and_belongs_to_many :users
  has_and_belongs_to_many :diagrams

  def name_cs
 'xxx'
#    competition.name + (name.nil? ? '' : ' / ' + name)
  end
end
