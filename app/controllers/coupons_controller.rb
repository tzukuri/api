class CouponsController < ApplicationController

  def validate
    @coupon = Coupon.get(params[:coupon])

    if @coupon.nil?
      render json: {
        exists: false
      }
      return
    end

    render json: {
      exists: true,
      coupon: @coupon
    }
  end

end
