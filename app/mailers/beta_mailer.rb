class BetaMailer < ActionMailer::Base
  default from: "beta@tzukuri.com"

  def send_beta_confirmation_email(beta_signup)
    puts "SENDING EMAIL"
    puts beta_signup
    @beta_signup = beta_signup
    mail(to: @beta_signup.email, subject:"Welcome to the Tzukuri Beta!")
  end
end
