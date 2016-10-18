class PreordersController < ApplicationController

    # create a new preorder and charge the customer's card
    def create
        preorder = Preorder.create(preorder_params.except(:token))

        if preorder.valid?

          begin
            customer = Stripe::Customer.create(
              card: preorder_params[:token],
              description: preorder_params[:name],
              email: preorder_params[:email],
              metadata: {
                preorder_discount: preorder.code,
                preorder_remain: preorder.amount_remaining
              }
            )

            charge = Stripe::Charge.create(
              amount: 8500,
              currency: 'aud',
              customer: customer.id,
              description: "[PREORDER] - #{preorder_params[:frame].titleize}, #{preorder_params[:size].titleize}, #{preorder_params[:utility].titleize}, #{preorder_params[:lens].titleize}"
            )

            # update the preorder with charge.id and customer.id
            preorder.update_attributes({
                customer_id: customer.id,
                charge_id: charge.id
            })

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

        else

          render json: {
            success: false,
            errors: preorder.errors,
            full_errors: preorder.errors.full_messages
          }

        end
    end

    private

    def preorder_params
        params.permit(:name, :email, :phone, {address_lines: []}, :country, :state, :postal_code, :utility, :frame, :size, :lens, :customer_id, :charge_id, :token, :code)
    end
end
