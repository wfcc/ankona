#Object.send(:remove_const, :Version)
class Version < ActiveRecord::Base
  belongs_to :diagram

  def fef5
    (Digest::MD5.new << fef).to_s[0..3]
  end
end

