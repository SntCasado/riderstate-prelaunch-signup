# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :confirmed_at, :created_at, :betatester, :distance, :club_id

  has_many :activities
  has_and_belongs_to_many :events
  has_many :friendship

  #has_many :friends, 
  #         :through => :friendships,
  #         :conditions => "status = 'accepted'", 
  #         :order => :id

  #has_many :requested_friends, 
  #         :through => :friendships, 
  #         :source => :friend,
  #         :conditions => "status = 'requested'", 
  #         :order => :created_at

  #has_many :pending_friends, 
  #         :through => :friendships, 
  #         :source => :friend,
  #         :conditions => "status = 'pending'", 
  #         :order => :created_at

  # override Devise method
  # no password is required when the account is created; validate password when the user sets one
  def password_required?
    if !persisted? 
      false
    else
      !password.nil? || !password_confirmation.nil?
    end
  end
  
  # override Devise method
  def confirmation_required?
    true
  end
  
  # override Devise method
  def active_for_authentication?
    confirmed? || confirmation_period_valid?
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver
  end

  # new function to set the password
  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end

  # new function to determine whether a password has been set
  def has_no_password?
    self.encrypted_password.blank?
  end

  # new function to provide access to protected method pending_any_confirmation
  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end

  # send confirmation to a group's new users (added by the admin group)
  def send_confirmation_instructions
    generate_confirmation_token! if self.confirmation_token.nil?
    ::Devise.mailer.confirmation_instructions(self).deliver
  end
end
