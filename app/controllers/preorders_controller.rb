class PreordersController < ApplicationController
    DOLLARS = 100

    def create
        @amount = 485 * DOLLARS
        @final_amount = @amount

        # calculate any discount that should be applied from the coupon code
        code = preorder_params[:coupon]

        if !code.blank?
          @coupon = Coupon.get(code)

          if @coupon.nil?
            # this is an invalid coupon, or it doesn't exist, render an error
            render json: {
              success: false,
              errors: ["The discount code you provided was invalid."]
            }
            return
          else
            @final_amount = @coupon.apply_discount(@amount)
            @discount_amount = @amount - @final_amount
          end
        end

        # create the preorder params and merge the coupon id if one exists
        build_params = preorder_params.except(:token, :coupon)
        build_params.merge!({coupon_id: @coupon.id}) unless @coupon.nil?

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
            amount: @final_amount,
            currency: 'aud',
            customer: customer.id,
            description: "[PREORDER] - #{preorder_params[:frame].titleize}, #{preorder_params[:size].titleize}, #{preorder_params[:utility].titleize}, #{preorder_params[:lens].titleize}"
          )

          tzu_charge = Charge.create(customer_id: customer.id, charge_id: charge.id, amount: @final_amount)

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

    private

    def preorder_params
        params.permit(:name, :email, :phone, {address_lines: []}, :country, :state, :postal_code, :utility, :frame, :size, :lens, :customer_id, :charge_id, :token, :coupon)
    end
end
