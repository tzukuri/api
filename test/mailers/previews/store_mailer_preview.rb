# Preview all emails at http://localhost:3000/rails/mailers/store_mailer
class StoreMailerPreview < ActionMailer::Preview
  def send_preorder_confirmation
    StoreMailer.preorder_confirmation(Preorder.last)
  end
end
