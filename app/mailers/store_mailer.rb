# mailer for all email related to the store, purchase confirmations
# shipping confirmations, etc.
class StoreMailer < ActionMailer::Base
  default :from => "\"Tzukuri\" <hello@tzukuri.com>"

  # send an email confirming a purchase
  def preorder_confirmation(preorder)
    @preorder = preorder
    mail(to: preorder.email, subject: "Thanks for your purchase")
  end

  # send an email confirming an interest registration
  def interest_confirmation(interest)
    @interest = interest
    mail(to:interest.email, subject: "Thanks for your interest in Tzukuri")
  end
end
