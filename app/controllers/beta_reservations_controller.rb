class BetaReservationsController < ApplicationController

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

      if params[:address1].empty?
        render json: {success: false, reason: 'Please enter a valid address'}
        return;
      end

      if params[:state].empty?
        render json: {success: false, reason: 'Please enter a valid state'}
        return;
      end

      if params[:postcode].empty?
        render json: {success: false, reason: 'Please enter a valid postcode'}
        return;
      end

      if params[:country].empty?
        render json: {success: false, reason: 'Please enter a valid country'}
        return;
      end


      customer = Stripe::Customer.create(
          description: params[:name],
          email: params[:email]
      )

      # creates a purchase with a nil charge_id
      purchase = Purchase.create(
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
            customer_id: customer.id,
            charge_id: nil
        )

      render json: {success: true, purchase: purchase} if purchase.valid?
    end

  def show
    @betareservation = Purchase.where("purchases.charge_id IS NULL").find(params[:id])
  end

  def destroy
    Purchase.where("purchases.charge_id IS NULL").find(params[:id]).destroy
    redirect_to beta_reservation_path
  end

  def csv
    lines = ["date,name,email,frame,colour,size,customer_id"]
    Purchase.where("purchases.charge_id IS NULL").each do |betareservation|
      lines << "#{betareservation.created_at},#{betareservation.name},#{betareservation.email},#{betareservation.frame},#{betareservation.colour},#{betareservation.size}"
    end
    render text: lines.join("\n")
  end

end


