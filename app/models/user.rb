class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  # :validatable
  devise :database_authenticatable, :registerable, :encryptable,
         :recoverable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :author, :author_attributes, :author_id, :role_ids

  attr_accessible :nick
  cattr_accessor :current_user
  
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :sections
  has_many :competitions
  belongs_to :author, autosave: true

  has_many :collections
  validates_uniqueness_of :email
  accepts_nested_attributes_for :author

  #acts_as_authentic do |c|
  #  c.logged_in_timeout = 1
  #  c.transition_from_crypto_providers = Authlogic::CryptoProviders::Sha1
  #end

  def nick(you = true)
    nick = if self.author.present? 
      self.author.name
    elsif self.name.present?
      self.name
    else
      self.email
    end
    nick = nick + ' (you)' if you and self == current_user
    return nick
  end

  def deliver_password_reset_instructions
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end
end
