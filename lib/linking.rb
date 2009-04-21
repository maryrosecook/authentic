module Linking
  
  # returns host of website
  def self.get_host
    if production?
      return "http://authentic.com"
    else
      return "http://localhost:3000"
    end
  end
  
  # returns a verify link for the passed salt
  def self.verify_link(salt)
    get_host() + "/authentication/verify/" + salt
  end
  
  def self.production?
    ENV["RAILS_ENV"] == "production"
  end
end