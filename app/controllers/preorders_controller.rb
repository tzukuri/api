class PreordersController < ApplicationController
    EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    def create
        # todo: remove this
        # returning successful for now (not charging cards yet)
        render json: {success: true, ref: ""}
        return

        begin
            customer = Stripe::Customer.create(
                card: preorder_params[:token],
                description: preorder_params[:name],
                email: preorder_params[:email]
            )

            charge = Stripe::Charge.create(
                amount: 8500,
                currency: 'aud',
                customer: customer.id,
                description: "Tzukuri - #{preorder_params[:frame].titleize}, #{preorder_params[:size].titleize}, #{preorder_params[:utility]}, #{preorder_params[:lens]}} - #{preorder_params[:name]}"
            )

            preorder = Preorder.create(preorder_params.except(:token).merge(customer_id: customer.id, charge_id: charge.id))

            if preorder.valid?
                StoreMailer.preorder_confirmation(preorder).deliver_later
                render json: {success: true, ref: "#{preorder_params[:frame].downcase[0..3]}#{preorder.id}"}
            else
                render json: {success: false, errors: preorder.errors, full_errors: preorder.errors.full_messages}
            end

        rescue Stripe::CardError => e
            render json: {success: false, reason: e.json_body[:error][:message]}
        end

    end

    private

    def preorder_params
        params.permit(:name, :email, :phone, {address_lines: []}, :country, :state, :postal_code, :utility, :frame, :size, :lens, :customer_id, :charge_id, :token, :code)
    end
end
