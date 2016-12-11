# Preview all emails at http://localhost:3000/rails/mailers/store_mailer
class StoreMailerPreview < ActionMailer::Preview
  def send_preorder_confirmation
    StoreMailer.preorder_confirmation(Preorder.last)
  end

  def send_gift_confirmation
    StoreMailer.gift_confirmation(Gift.last)
  end

  def send_gift_redeemed
    StoreMailer.gift_redeemed(Gift.find(17))
  end
end
