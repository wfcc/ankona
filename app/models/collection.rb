class Collection < ActiveRecord::Base
  has_and_belongs_to_many :diagrams
  belongs_to :user
end
