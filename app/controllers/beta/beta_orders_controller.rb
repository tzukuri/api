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

      BetaMailer.send_beta_order_email(current_beta_user).deliver_later

      render :json => {success: true, beta_order: beta_order}
    end
  end

  private

  def beta_order_params
    params.permit(:address1, :address2, :state, :postcode, :country, :frame, :size, :phone, :delivery_method).merge(beta_user_id: current_beta_user.id)
  end

end
