class BetaMailer < ActionMailer::Base
  default from: "beta@tzukuri.com"

  def send_beta_confirmation_email(beta_user)
    @beta_user = beta_user
    mail(to: beta_user.email, subject:"Thanks for registering your interest in the Tzukuri Beta")
  end

  def send_beta_acceptance_email(beta_user)
    @beta_user = beta_user
    mail(to: beta_user.email, subject: "You've been selected to participate in the Tzukuri Beta")
  end

  def send_beta_forgot_link(beta_user)
    puts beta_user.email
    @beta_user = beta_user
    mail(to: beta_user.email, subject: "Your Tzukuri Beta login link")
  end

end
