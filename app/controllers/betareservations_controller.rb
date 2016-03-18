class BetareservationsController < ApplicationController
  http_basic_authenticate_with name: "a@tzukuri.com", password: "ksV-Pxq-646-feS", except: :create
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  def create
    if params[:name].empty?
      render json: {success: false, reason: 'Please enter your name.'}
      return
    end

    if params[:email].empty? || !(params[:email] =~ EMAIL_REGEX)
      render json: {success: false, reason: 'Please enter a valid email address.'}
      return
    end

    betareservation = Betareservation.create(
        name: params[:name],
        email: params[:email],
        address1: params[:address1],
        address2: params[:address2],
        state: params[:state],
        postcode: params[:postcode],
        country: params[:country],
        frame: params[:frame],
        colour: params[:colour],
        size: params[:size],
        model: params[:model]
    )

    render json: {success: true}

  end

  # def index
  #   @purchases = Purchase.all
  # end
  #
  # def show
  #   @purchase = Purchase.find(params[:id])
  # end
  #
  # def destroy
  #   Purchase.find(params[:id]).destroy
  #   redirect_to purchases_path
  # end
  #
  # def csv
  #   lines = ["date,name,email,frame,colour,size,customer_id"]
  #   Purchase.all.each do |purchase|
  #     lines << "#{purchase.created_at},#{purchase.name},#{purchase.email},#{purchase.frame},#{purchase.colour},#{purchase.size},#{purchase.customer_id}"
  #   end
  #   render text: lines.join("\n")
  # end
end
