class CouponsController < ApplicationController

  def validate
    @token = Coupon.get(params[:coupon]) || Gift.get(params[:coupon])

    if @token.nil?
      render json: {
        exists: false
      }
      return
    end

    render json: {
      exists: true,
      type: @token.class.name.upcase,
      token: @token
    }
  end

end
