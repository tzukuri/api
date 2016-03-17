class RsvpsController < ApplicationController
  http_basic_authenticate_with name: "a@tzukuri.com", password: "ksV-Pxq-646-feS", except: :create
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  def create
    if params[:rsvp][:email].empty? || !(params[:rsvp][:email] =~ EMAIL_REGEX)
      render json: {success: false, reason: 'Email invalid, try again.'}
      return
    end

    rsvp = Rsvp.create(name: params[:rsvp][:name], email: params[:rsvp][:email], inviter: params[:rsvp][:inviter]);

    render json: {success: true}
  end

  def index
    @rsvps = Rsvp.all
  end

  def show
    @rsvps = Rsvp.find(params[:id])
  end

  def csv
    lines = ["name, email, inviter, created_at"]

    Rsvp.all.each do |rsvp|
      lines << "#{rsvp.name}, #{rsvp.email}, #{rsvp.inviter}, #{rsvp.created_at}"
    end

    render text: lines.join("\n")
  end

end
