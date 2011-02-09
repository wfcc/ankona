class User < ActiveRecord::Base

  has_and_belongs_to_many :roles
  has_and_belongs_to_many :sections
  belongs_to :author, autosave: true

  has_many :collections
  validates_uniqueness_of :login

  acts_as_authentic do |c|
    c.logged_in_timeout = 1
    c.transition_from_crypto_providers = Authlogic::CryptoProviders::Sha1
  end

  def deliver_password_reset_instructions
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end
  def email=(login)
    write_attribute(:login, login)
  end
  def email
    login
  end
end
