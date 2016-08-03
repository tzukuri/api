class BetaOrdersController < ApplicationController
  def create
    begin
      beta_order = BetaOrder.create(beta_order_params)

      # todo: handle invalid beta order if charge is successful
      if !beta_order.valid?
        render :json => {success: false, errors: beta_order.errors}
        return
      end

      # set up the delivery timeslot as well
      if beta_order.delivery_method == "deliver"
          beta_order.update_attribute('beta_delivery_timeslot_id', params[:delivery_timeslot_id])
      end

      customer = Stripe::Customer.create(
        card: params[:token],
        description: current_beta_user.name,
        email: current_beta_user.email
      )

      charge = Stripe::Charge.create(
        amount: 9999,
        currency: 'aud',
        customer: customer.id,
        description: 'Tzukuri Beta Delivery Fee'
      )

      # update the order with the charge/customer ids
      beta_order.update_attribute('charge_id', charge.id)
      beta_order.update_attribute('customer_id', customer.id)

      render :json => {success: true, beta_order: beta_order}

    rescue Stripe::CardError => e
      # card failed to charge so destroy the order
      p "destroying order"
      beta_order.destroy()

      render json: {success: false, reason: e.json_body[:error][:message]}
    end
  end

  private

  def beta_order_params
    params.permit(:address1, :address2, :state, :postcode, :country, :frame, :size, :phone, :delivery_method).merge(beta_user_id: current_beta_user.id)
  end

end
