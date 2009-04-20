class User < ActiveRecord::Base
   
  # creates new user, adds email and p/w and encrypts password
  def new_from_registration(email, password)
    user = self.new()
    user.email = email
    user.password = password
    user.encrypt_password()
    return user
  end

  def encrypt_password
    self.password_encryption_salt = Digest::SHA1.hexdigest(Time.now.to_s) if !self.salt
    self.encrypted_password = encrypt_str(password)
  end
  
  def self.encrypt_str(password)
    self.class.encrypt(password, salt)
  end
  
  def self.authenticated?(email, password)
    authenticated = false
    if user = self.find_by_email(email)
      if user.encryped_password == encrypt_str(password)
        authenticated = true
      end
    end
    
    return authenticated
  end
end