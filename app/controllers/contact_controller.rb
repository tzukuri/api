class ContactController < ApplicationController
  def create
    enquiry = Enquiry.new(enquiry_params)

    if enquiry.valid?
      ContactUsMailer.new_enquiry(enquiry).deliver_now
      render json: { success: true, notice: 'Thanks for getting in touch'}
    else
      render json: { success: false, errors: enquiry.errors, full_errors: enquiry.errors.full_messages }
    end
  end

private

  def enquiry_params
    params.require(:enquiry).permit(:name, :email, :content)
  end

end
