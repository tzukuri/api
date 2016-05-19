class BetaMailer < ActionMailer::Base
  default from: "beta@tzukuri.com"

  def send_beta_confirmation_email(beta_user)
    @beta_user = beta_user
    mail(to: @beta_user.email, subject:"Thanks for registering for the Tzukuri Beta")
  end

  def send_beta_acceptance_email(beta_user)
    @beta_user = beta_user
    mail(to: @beta_user.email, subject: "Congratulations, you've been selected to participate in the Tzukuri Beta")
  end
end
