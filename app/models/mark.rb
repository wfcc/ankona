class Mark < ActiveRecord::Base
  belongs_to :diagram
  belongs_to :section
end
