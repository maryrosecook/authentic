class AuthenticationController < ApplicationController
  
  # authenticates with send email and password
  def authenticate
    @authenticated = User.authenticated?(params[:email], params[:password], request.remote_ip)
    
    respond_to do |format|
      format.html
      format.xml
    end
  end
  
  # signs up user by sending email and password
  def signup
    @signed_up = false
    new_user = User.new_from_signup(params[:email], params[:password])
    if new_user && new_user.save()
      @signed_up = "true"
    end
    
    respond_to do |format|
      format.html
      format.xml
    end
  end
  
  # looks for user w/ passed salt.  If found, sets them to verified.
  def verify
    @verified = false
    if salt = params[:id]
      if user = User.find_by_salt(salt)
        user.verified = true
        @verified = true if user.save()
      end
    end
    
    respond_to do |format|
      format.html
      format.xml
    end
  end
end