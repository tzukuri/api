# Preview all emails at http://localhost:3000/rails/mailers/beta_mailer
class BetaMailerPreview < ActionMailer::Preview

  def send_beta_confirmation_email
    BetaMailer.send_beta_confirmation_email(BetaUser.third)
  end

  def send_beta_acceptance_email
    BetaMailer.send_beta_acceptance_email(BetaUser.third)
  end

  def send_beta_forgot_link
    BetaMailer.send_beta_forgot_link(BetaUser.third)
  end
end
