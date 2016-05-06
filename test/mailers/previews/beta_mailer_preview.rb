# Preview all emails at http://localhost:3000/rails/mailers/beta_mailer
class BetaMailerPreview < ActionMailer::Preview

  def beta_welcome
    BetaMailer.send_beta_confirmation_email(BetaSignup.first)
  end

end
