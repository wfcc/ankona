#Object.send(:remove_const, :Version)
class Version < ActiveRecord::Base
  belongs_to :diagram
end
