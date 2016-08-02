class BetaOrdersController < ApplicationController
  def create

    # todo: validate the params

    # create a stripe customer
    customer = Stripe::Customer.create(
        card: params[:token],
        description: current_beta_user.name,
        email: current_beta_user.email
    )

    begin

      charge = Stripe::Charge.create(
        amount: 9999,
        currency: 'aud',
        customer: customer.id,
        description: 'Tzukuri Beta Delivery Fee'
      )

      beta_order = BetaOrder.create(
        beta_user_id: current_beta_user.id,
        address1: params[:address1],
        address2: params[:address2],
        state: params[:state],
        postcode: params[:postcode],
        country: params[:country],
        frame: params[:frame],
        size: params[:size],
        phone: params[:phone],
        delivery_method: params[:delivery_method],
        charge_id: charge.id,
        customer_id: customer.id
      )

      # todo: handle invalid beta order if charge is successful
      if !beta_order.valid?
        render :json => {success: false, errors: beta_order.errors}
        return
      end

      # set up the delivery timeslot as well
      if beta_order.delivery_method == "deliver"
        beta_order.update_attribute('beta_delivery_timeslot_id', params[:delivery_timeslot_id])
      end

      render :json => {success: true, beta_order: beta_order}

    rescue Stripe::CardError => e
      render json: {success: false, reason: e.json_body[:error][:message]}
    end
  end

  private

  def beta_order_params
    params.permit(:frame, :size, :address1, :address2, :state, :postcode, :country, :phone, :delivery_method).except(:delivery_timeslot_id).merge(:beta_user_id => current_beta_user.id)
  end

end
