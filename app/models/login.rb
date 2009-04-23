class Login < ActiveRecord::Base
  
  validates_length_of :email, :ip, :outcome,    :within => 1..9999
  validates_presence_of :email, :ip, :outcome
  
  SUCCEEDED = true
  FAILED = false
  
  TOO_MANY_ATTEMPTS = "Too many attempts"
  WRONG_EMAIL_OR_PASSWORD = "Wrong email or password"
  USER_NOT_VERIFIED = "Account not verified"
  
  def self.new_for_login(email, ip, outcome)
    login = self.new()
    login.email = email
    login.ip = ip
    login.outcome = FAILED
    
    return login
  end
end