class BetaOrdersController < ApplicationController
  def create
    # create an order by merging params and current user id
    delivery_timeslot_id = params[:delivery_timeslot_id]
    beta_order = BetaOrder.create(beta_order_params)

    if !beta_order.valid?
      render :json => {success: false, errors: beta_order.errors}
      return
    else
      # todo: check if the delivery method is hand delivery and assign the appropriate timeslot
      puts 'delivery timeslot id: ' + delivery_timeslot_id.to_s

      if beta_order.delivery_method == "deliver"
        beta_order.update_attribute('beta_delivery_timeslot_id', delivery_timeslot_id)
      end

      render :json => {success: true, beta_order: beta_order}
    end
  end

  private

  def beta_order_params
    params.permit(:frame, :size, :address1, :address2, :state, :postcode, :country, :phone, :delivery_method).except(:delivery_timeslot_id).merge(:beta_user_id => current_beta_user.id)
  end

end
