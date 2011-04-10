class Section < ActiveRecord::Base
  belongs_to :competition
  belongs_to :user
  has_and_belongs_to_many :users
  has_and_belongs_to_many :diagrams
  has_many :marks

  def name_cs
# 'xxx'
    (competition.nil? ? '' : competition.name.to_s) + (name.nil? ? '' : ' / ' + name)
  end
end
