class User < ActiveRecord::Base
   
  validates_length_of :email,    :within => 1..9999
  validates_format_of :email, :with => /\A([\w\.\-\+]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates_presence_of :email, :password
  
  NUMBER_OF_FAILED_LOGINS_FOR_LOCKOUT = 5

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

  def encrypt_password
    self.password_encryption_salt = Digest::SHA1.hexdigest(Time.now.to_s + self.email.to_s) if !self.salt
    self.encrypted_password = encrypt_str(password)
  end
  
  def self.encrypt_str(password)
    self.class.encrypt(password, salt)
  end
  
  def send_verify_email
    Mailing::deliver_account_verify_email(self)
  end
  
  def verify_link
    Linking::verify_link(self.salt)
  end
  
  # returns true if user exists w/ email and password 
  def self.authenticated?(email, password, ip)
    authenticated = false
    if user = self.find_by_email(email) # found a user with that email
      if user.unlocked?(ip) # user account hasn't been locked because of too many failed login attempts
        if user.encryped_password == encrypt_str(password) # passwords match
          authenticated = true
        end
      end
    end
    
    authenticated
  end
  
  # get NUMBER_OF_FAILED_LOGINS_FOR_LOCKOUT most recent logins for ip and email.  If any were successful, account is unlocked.
  def unlocked?(ip)
    unlocked = false
    if ip
      for recent_login in Login.find( :all, 
                                      :conditions => "email = '#{self.email}'
                                                      && ip = '#{ip}'",
                                      :order => "date DESC",
                                      :limit => NUMBER_OF_FAILED_LOGINS_FOR_LOCKOUT)
                                    
        unlocked = true if recent_login.outcome == Login::SUCCEEDED
      end
    end
    
    unlocked
  end
end