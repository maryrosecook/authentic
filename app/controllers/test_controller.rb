class TestController < ApplicationController
  before_filter :logged_in?, :only => { :profile }
  
  # all users can access here
  def index
  end
  
  # user profile area - users must authenticate
  def profile
    
  end
  
  private
  
    # called when accessing a private area - does basic auth either via headers or user-entered email and password
    def authenticate
      authenticate_or_request_with_http_basic do |email, password| 
        User.authenticated?(email, password, request.remote_ip)
      end
    end
end