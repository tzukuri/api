class ContactUsMailer < ActionMailer::Base
  default to: "hello@tzukuri.com"

  def new_enquiry(enquiry)
    @enquiry = enquiry
    mail(from: enquiry.email, subject: "Tzukuri | Enquiry from #{enquiry.name}")
  end

end
