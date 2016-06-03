class BetaOrdersController < ApplicationController

  def create
    # create an order by merging params and current user id
    beta_order = BetaOrder.create(beta_order_params.merge(:beta_user_id => current_beta_user.id))

    if !beta_order.valid?
      render :json => {success: false, errors: beta_order.errors}
      return
    else
      render :json => {success: true, beta_order: beta_order}
    end
  end

  private

  def beta_order_params
    params.require(:beta_order).permit(:address1, :address2, :state, :postcode, :country, :frame, :size)
  end
end