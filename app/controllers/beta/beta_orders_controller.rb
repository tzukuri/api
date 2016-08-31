class BetaOrdersController < ApplicationController

  http_basic_authenticate_with name: "beta@tzukuri.com", password: "ksV-Pxq-646-feS", only: [:all, :date]

  def create
    beta_order = BetaOrder.create(beta_order_params)

    # if we have start and end times, try to create a booking
    if params[:timeslot_start].present? && params[:timeslot_end].present?
      begin
        beta_order.create_delivery_booking(params[:timeslot_start], params[:timeslot_end])
      rescue => e
        beta_order.destroy
        render :json => {success: false, errors: ["An error ocurred creating your booking. Please try again."]}
        return
      end
    end

    if !beta_order.valid?
      render :json => {success: false, errors: beta_order.errors}
      return
    end

    beta_order.send_confirmation_email
    render :json => {success: true, beta_order: beta_order}
  end

  private

  def beta_order_params
    params.permit(:shipping_name, :address1, :address2, :state, :postcode, :country, :frame, :size, :phone, :delivery_method).merge(beta_user_id: current_beta_user.id)
  end

end
