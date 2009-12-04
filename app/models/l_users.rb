class LUsers < ActiveRecord::Base
  def email
    login
  end
end
