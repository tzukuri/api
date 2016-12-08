class GiftsController < ApplicationController
    DOLLARS = 100
    FULL_PRICE = 485 * DOLLARS

    def create
      code = gift_params[:coupon]
      full_amount = FULL_PRICE

      @coupon = Coupon.get(code) if !code.blank?

      if @coupon.nil? && !code.blank?
        render json: {
          success: false,
          errors: ["The deposit token you provided was invalid."]
        }
        return
      elsif !@coupon.nil?
        full_amount = @coupon.apply_discount(full_amount)
      end

      # create a new gift
      @gift = Gift.create(gift_params.except(:coupon, :token))

      # attempt to charge card

      # if the preorder is not valid, return an error (there was some error creating the preorder)
      if !@gift.valid?
        render json: {
          success: false,
          errors: @gift.errors,
          full_errors: @gift.errors.full_messages
        }
        return
      end

      # the preorder is valid so attempt to charge the card
      begin
        customer = Stripe::Customer.create(
          card: gift_params[:token],
          description: gift_params[:purchased_by],
          email: gift_params[:purchased_by]
        )

        charge = Stripe::Charge.create(
          amount: full_amount,
          currency: 'aud',
          customer: customer.id,
          description: "[GIFT] - #{gift_params[:purchased_by]}"
        )

        tzu_charge = Charge.create(customer_id: customer.id, charge_id: charge.id, amount: full_amount)

        @gift.update_attributes(charge_id: tzu_charge.id)

        # todo: send confirmation

        render json: {
          success: true,
          gift: @gift
        }

      rescue Stripe::CardError => error
        @gift.destroy

        render json: {
          success: false,
          errors: error.json_body[:error][:message]
        }
      end
    end

    private

    def gift_params
      params.permit(:purchased_by, :token, :coupon)
    end
end
