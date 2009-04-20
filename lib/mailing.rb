require 'net/imap'

class Mailing < ActionMailer::Base

  VERIFY_REPLY_TO_EMAIL_ADDRESS = "noreply@authentic.com"

  # sends an account verification email for this user
  def account_verify_email(new_user)
    recipients new_user.email
    from VERIFY_REPLY_TO_EMAIL_ADDRESS
    reply_to = VERIFY_REPLY_TO_EMAIL_ADDRESS
    subject "Please verify your new Authentic account"

    body[:email] = new_user.email
    body[:verify_link] = user.verify_link()
  end
end
