class AuthenticationController < ApplicationController
  
  def authenticate
    @authenticated = User.authenticated?(params[:email], params[:password])
    respond_to do |format|
      format.html
      format.xml
    end
  end
  
  def signup
    
  end
end