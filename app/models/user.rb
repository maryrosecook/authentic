require 'digest/sha1'

class User < ActiveRecord::Base
   
  validates_length_of :email,    :within => 1..9999
  validates_format_of :email, :with => /\A([\w\.\-\+]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates_presence_of :email, :password
  validates_uniqueness_of :email
  
  NUMBER_OF_FAILED_LOGINS_FOR_LOCKOUT = 5
  THRESHOLD_IN_SECONDS = 60 * 5 # five mins
  
  # creates new user, adds email and p/w and encrypts password
  def self.new_from_signup(email, password)
    user = nil
    if email && password
      user = self.new()
      user.email = email
      user.password = password
      user.encrypt_password()
    end
    
    user
  end
  
  def send_verify_email
    Mailing::deliver_account_verify_email(self)
  end
  
  def verify_link
    Linking::verify_link(self.salt)
  end
  
  # returns true if user exists w/ email and password 
  def self.authenticated?(email, password, ip)
    login = Login.new_for_login(email, ip, Login::FAILED) # record login with initial failure
    
    if user = self.find_by_email(email) # found a user with that email
      if user.verified == 1
        if user.unlocked?(ip) # user account hasn't been locked because of too many failed login attempts
          if user.encrypted_password == encrypt_str(password, user.salt) # passwords match
            login.outcome = Login::SUCCEEDED
          else
            login.failure_reason = Login::WRONG_EMAIL_OR_PASSWORD
          end
        else # failed because too many tries from this ip with this email
          login.failure_reason = Login::TOO_MANY_ATTEMPTS
        end
      else # user hasn't verified their account
        login.failure_reason = Login::USER_NOT_VERIFIED
      end
    end
    
    login.save()
    return login
  end
  
  # gets NUMBER_OF_FAILED_LOGINS_FOR_LOCKOUT login attempts made after login_attempt_threshold() for ip and email.  If any were
  # were successful, user is unlocked for logging in.
  def unlocked?(ip)
    unlocked = false
    if ip
      recent_logins = Login.find( :all, 
                                  :conditions => "email = '#{self.email}'
                                                  && ip = '#{ip}'",
                                  :order => "created_at DESC",
                                  :limit => NUMBER_OF_FAILED_LOGINS_FOR_LOCKOUT)

      if recent_logins.length > 0
        for recent_login in recent_logins
          if recent_login.outcome == 1 || User.login_attempt_threshold.tv_sec > recent_login.created_at.tv_sec  # found successful login or passed login attempt threshold
            unlocked = true
            break
          end
        end
      else
        unlocked = true
      end
    end
    
    unlocked
  end
  
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest(salt + password)
  end

  def encrypt_password
    self.salt = Digest::SHA1.hexdigest(Time.now.to_s + self.email.to_s) if !self.salt
    self.encrypted_password = User.encrypt_str(self.password, self.salt)
  end
  
  def self.encrypt_str(password, salt)
    encrypt(password, salt)
  end
  
  # returns a time before which login attempts are disregarded
  def self.login_attempt_threshold
    return Time.now() - THRESHOLD_IN_SECONDS
  end
end