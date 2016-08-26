class BetaOrdersController < ApplicationController

  http_basic_authenticate_with name: "beta@tzukuri.com", password: "ksV-Pxq-646-feS", only: [:all, :date]

  def create
    begin
      # if the user is getting personal delivery create an order with delivery timeslot
      if params[:timeslot_start].present? && params[:timeslot_end].present?
        # create an order with timeslot_start
        start_time = params[:timeslot_start]
        end_time = params[:timeslot_end]

        beta_order = BetaOrder.create(beta_order_params.merge(delivery_time: start_time))

        # send a booking request to TimeKit
        event = {
          start: start_time.to_time.iso8601,
          end: end_time.to_time.iso8601,
          what: 'Tzukuri Personal Fitting - ' + current_beta_user.name,
          where: beta_order.full_address,
          calendar_id: '348c52b6-ae68-40d3-9781-2ea308505f04',
          description: ''
        }

        customer = {
          name: current_beta_user.name,
          email: current_beta_user.email,
          phone: beta_order.phone,
          voip: '',
          # fixme: assuming that everyone is in Sydney for now
          timezone: 'Australia/Sydney'
        }

        # don't notify the customer by email, we'll send our own confirmation
        notify = {
          enabled: false
        }

        # create a new timekit instance, all bookings all go into the beta@tzukuri.com calendar
        # eventually, we'll probably want to change this and have a seperate email for handling bookings
        timekit = Tzukuri::Timekit.new("beta@tzukuri.com", 'XAuyu7wMLLjSlF6pltBJR4x8d4W3tN7W')

        begin
          response = timekit.create_booking(event, customer, notify)

          # update the beta order with the Timekit booking id
          booking = JSON.parse(response.body)
          beta_order.update_attribute('booking_id', booking["data"]["id"])
        rescue => e
          # if there was an error creating the booking, destroy the order and return an error
          beta_order.destroy
          render :json => {success: false, errors: ["An error ocurred creating your booking. Please try again."]}
          return
        end
      else
        beta_order = BetaOrder.create(beta_order_params)
      end

      if !beta_order.valid?
        render :json => {success: false, errors: beta_order.errors}
        return
      end

      beta_order.send_confirmation_email
      render :json => {success: true, beta_order: beta_order}
    end
  end

  private

  def beta_order_params
    params.permit(:address1, :address2, :state, :postcode, :country, :frame, :size, :phone, :delivery_method).merge(beta_user_id: current_beta_user.id)
  end

end
