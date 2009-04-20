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
    @signup_success = false
    new_user = User.new_from_signup(params[:email], params[:password])
    if new_user.save()
      @signup_success = "true"
    end
  end
end