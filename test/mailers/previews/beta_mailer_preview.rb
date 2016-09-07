# Preview all emails at http://localhost:3000/rails/mailers/beta_mailer
class BetaMailerPreview < ActionMailer::Preview

  def send_purchase_confirmation_email
    BetaMailer.send_purchase_confirmation_email(Purchase.find(3))
  end

  def send_beta_confirmation_email
    BetaMailer.send_beta_confirmation_email(BetaUser.first)
  end

  def send_beta_acceptance_email
    BetaMailer.send_beta_acceptance_email(BetaUser.first)
  end

  def send_beta_forgot_link
    BetaMailer.send_beta_forgot_link(BetaUser.first)
  end

  def send_beta_order_email
    BetaMailer.send_beta_order_email(BetaUser.first)
  end
end
