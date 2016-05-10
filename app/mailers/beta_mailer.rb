class BetaMailer < ActionMailer::Base
  default from: "beta@tzukuri.com"

  def send_beta_confirmation_email(beta_signup)
    @beta_signup = beta_signup
    mail(to: @beta_signup.email, subject:"Thanks for registering for the Tzukuri Beta")
  end

  def send_beta_acceptance_email(beta_signup)
    @beta_signup = beta_signup
    mail(to: @beta_signup.email, subject: "Congratulations, you've been selected to participate in the Tzukuri Beta")
  end
end
