class PreordersController < ApplicationController
    DOLLARS = 100
    FULL_PRICE = 485 * DOLLARS


    def create
      code = preorder_params[:coupon]

      @coupon = Coupon.get(code) if !code.blank?
      @gift = Gift.get(code) if !code.blank?

      if !@coupon.nil?
        puts "HANDLING COUPON"
        handle_coupon(@coupon)
      elsif !@gift.nil?
        puts "HANDLING GIFT"
        handle_gift(@gift)
      elsif !code.blank?
        puts "HANDLING INVALID TOKEN"
        handle_invalid_token
        return
      else
        puts "HANDLING REGULAR PAYMENT"
        handle_payment(FULL_PRICE)
      end
    end

    private

    def preorder_params
        params.permit(:name, :email, :phone, {address_lines: []}, :country, :state, :postal_code, :utility, :frame, :size, :lens, :customer_id, :charge_id, :token, :coupon)
    end

    # calculate the coupon discount and then call handle payment to make the payment
    def handle_coupon(coupon)
      amount = coupon.apply_discount(FULL_PRICE)
      handle_payment(amount, coupon)
    end

    # create a preorder without needing to charge the card
    def handle_gift(gift)

      build_params = preorder_params.except(:token, :coupon)
      build_params.merge!({gift_id: gift.id})

      preorder = Preorder.create(build_params)

      if !preorder.valid?
        render json: {
          success: false,
          errors: preorder.errors,
          full_errors: preorder.errors.full_messages
        }
        return
      else
        preorder.send_confirmation

        render json: {
          success: true,
          preorder: preorder
        }
      end

    end

    # handle a payment with a coupon
    def handle_payment(final_amount, coupon = nil)
      # create the preorder params and merge the coupon id if one exists
      build_params = preorder_params.except(:token, :coupon)
      build_params.merge!({coupon_id: coupon.id}) unless coupon.nil?

      preorder = Preorder.create(build_params)

      # if the preorder is not valid, return an error (there was some error creating the preorder)
      if !preorder.valid?
        render json: {
          success: false,
          errors: preorder.errors,
          full_errors: preorder.errors.full_messages
        }
        return
      end

      # the preorder is valid so attempt to charge the card
      begin
        customer = Stripe::Customer.create(
          card: preorder_params[:token],
          description: preorder_params[:name],
          email: preorder_params[:email]
        )

        charge = Stripe::Charge.create(
          amount: final_amount,
          currency: 'aud',
          customer: customer.id,
          description: "[PREORDER] - #{preorder_params[:frame].titleize}, #{preorder_params[:size].titleize}, #{preorder_params[:utility].titleize}, #{preorder_params[:lens].titleize}"
        )

        tzu_charge = Charge.create(customer_id: customer.id, charge_id: charge.id, amount: final_amount)

        preorder.update_attributes(charge_id: tzu_charge.id)

        preorder.send_confirmation

        render json: {
          success: true,
          preorder: preorder
        }

      rescue Stripe::CardError => error
        preorder.destroy

        render json: {
          success: false,
          errors: error.json_body[:error][:message]
        }
      end
    end

    # render an error if we detect a token that is invalid
    def handle_invalid_token
        render json: {
          success: false,
          errors: ["The deposit token you provided was invalid."]
        }
    end
end
