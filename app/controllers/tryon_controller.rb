class TryonController < ApplicationController

  def validate
    # id for try on mailing list
    mailing_list = 'c94da29898b877b990a6ce1f7c76828e'
    auth = {api_key: 'eb99798ca9551efbad763f40fd73b5f7'}

    email = tryon_params['email']
    name = tryon_params['name']
    custom_fields = [
      {Key: 'city', Value: tryon_params['city']},
      {Key: 'user_agent', Value: request.user_agent},
      {Key: 'ip_address', Value: request.remote_ip}
    ]

    sub_success = true
    valid_email = true

    begin
      CreateSend::Subscriber.add(auth, mailing_list, email, name, custom_fields, false)
    rescue CreateSend::BadRequest => br
      # if there was an error validating the email, we want to show an error to the user
      valid_email = br.data.Code != 1
      sub_success = false
    rescue Exception => e
      # if there was an exception, don't expose to the user, but note the sub was unsuccessful
      sub_success = false
    end

    render json: {
      valid_email: valid_email,
      allow: tryon_params['city'] == "Sydney",
      city: tryon_params['city'],
      name: name,
      email: email
    }
  end

  private

  def tryon_params
      params.permit(:name, :email, :city)
  end

end
