class BetaMailer < ActionMailer::Base
  default :from => "\"Tzukuri Beta\" <beta@tzukuri.com>"

  def send_beta_confirmation_email(beta_user)
    @beta_user = beta_user
    mail(to: beta_user.email, subject:"Thanks for registering for the Tzukuri Beta")
  end

  def send_purchase_confirmation_email(purchase)
    @purchase = purchase
    mail(to: purchase.email, subject:"Your Tzukuri Pre-order")
  end

  def send_beta_order_email(beta_user)
    @beta_user = beta_user
    @beta_order = beta_user.order

    mail(to:beta_user.email, subject: "Your Tzukuri Beta Order")
  end

  def send_beta_acceptance_email(beta_user)
    @beta_user = beta_user
    mail(to: beta_user.email, subject: "You're in")
  end

  def send_beta_forgot_link(beta_user)
    @beta_user = beta_user
    mail(to: beta_user.email, subject: "Your Tzukuri Beta dashboard link")
  end

  def send_score_conflict_alert(file_path, force_update)
    @file_path = file_path
    @force_update = force_update
    mail(to: 'sam@tzukuri.com, w@tzukuri.com', subject: "Alert - Incorrect Beta User Scores")
  end



end
