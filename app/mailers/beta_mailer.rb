class BetaMailer < ActionMailer::Base
  default :from => "\"Tzukuri Beta\" <beta@tzukuri.com>"

  def send_beta_confirmation_email(beta_user)
    @beta_user = beta_user
    mail(to: beta_user.email, subject:"Thanks for registering for the Tzukuri Beta")
  end

  def send_beta_acceptance_email(beta_user)
    @beta_user = beta_user
    mail(to: beta_user.email, subject: "You've been selected to participate in the Tzukuri Beta")
  end

  def send_beta_forgot_link(beta_user)
    @beta_user = beta_user
    mail(to: beta_user.email, subject: "Your Tzukuri Beta dashboard link")
  end

  def send_score_conflict_alert(file_path)
    @file_path = file_path
    mail(to: ['sam@tzukuri.com', 'w@tzukuri.com'], subject: "Alert - Incorrect Beta User Scores")
  end

end
