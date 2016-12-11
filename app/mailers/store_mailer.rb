# mailer for all email related to the store, purchase confirmations
# shipping confirmations, etc.
class StoreMailer < ActionMailer::Base
  default :from => "\"Tzukuri\" <hello@tzukuri.com>"

  # sent from: Preorder controller - when Preorder is created (after card is charged)
  def preorder_confirmation(preorder)
    @preorder = preorder
    mail(to: preorder.email, subject: "Thanks for ordering your Tzukuris")
  end

  # sent from: Gift controller - when Gift is created (after card is charged)
  def gift_confirmation(gift)
    @gift = gift
    mail(to: gift.purchased_by, subject: "Thanks for purchasing a Tzukuri Gift Card")
  end

  # sent from: Preorder controller - when gift is redeemed
  def gift_redeemed(gift)
    @gift = gift
    mail(to:gift.purchased_by, subject: "Your friend redeemed your Tzukuri Gift Card")
  end

  # todo: shipping update email (needs to be tied to be tied to the preorder being marked as in progress)

  # todo: shipped email (needs to be tied to the preorder being marked as shipped)
end
