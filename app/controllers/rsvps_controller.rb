class RsvpsController < ApplicationController

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  def create
    if params[:rsvp][:email].empty? || !(params[:rsvp][:email] =~ EMAIL_REGEX)
      render json: {success: false, reason: 'Email invalid, try again.'}
      return
    end

    rsvp = Rsvp.create(name: params[:rsvp][:name], email: params[:rsvp][:email], inviter: params[:rsvp][:inviter]);

    render json: {success: true}
  end

  # def csv
  #   lines = ["email,ip,created_at"]
  #   Email.all.each do |email|
  #     lines << "#{email.email},#{email.ip},#{email.created_at}"
  #   end
  #   render text: lines.join("\n")
  # end

end
