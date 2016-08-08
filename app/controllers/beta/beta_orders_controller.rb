class BetaOrdersController < ApplicationController

  http_basic_authenticate_with name: "beta@tzukuri.com", password: "ksV-Pxq-646-feS", only: [:all, :date]

  def create
    begin
      beta_order = BetaOrder.create(beta_order_params)

      # todo: handle invalid beta order if charge is successful
      if !beta_order.valid?
        render :json => {success: false, errors: beta_order.errors}
        return
      end

      # set up the delivery timeslot as well
      if beta_order.delivery_method == "deliver"
          beta_order.update_attribute('beta_delivery_timeslot_id', params[:delivery_timeslot_id])
      end

      BetaMailer.send_beta_order_email(current_beta_user).deliver_later

      render :json => {success: true, beta_order: beta_order}
    end
  end

  # get all orders
  def all
    csv_string = CSV.generate do |csv|
        csv << ['order_id', 'name', 'email', 'address1', 'address2', 'state', 'postcode', 'country', 'frame', 'size', 'phone', 'fulfilled', 'timeslot']

        BetaOrder.order(created_at: :desc).each do |beta_order|
          beta_user = beta_order.beta_user

          if !beta_order.beta_delivery_timeslot.nil?
            delivery_timeslot = beta_order.beta_delivery_timeslot.time
          else
            delivery_timeslot = 'nil'
          end

          csv << [beta_order.id, beta_user.name, beta_user.email, beta_order.address1, beta_order.address2, beta_order.state, beta_order.postcode, beta_order.country, beta_order.frame, beta_order.size, beta_order.phone, beta_order.fulfilled, delivery_timeslot]
        end
    end

    render body:csv_string
  end

  # get orders for a given delivery date (personal delivery only)
  # date format = mm-dd-yyyy
  def date
    date = params[:date]
    day = Date.parse(date)

    csv_string = CSV.generate do |csv|
      csv << ['order_id', 'name', 'email', 'address1', 'address2', 'state', 'postcode', 'country', 'frame', 'size', 'phone', 'fulfilled', 'timeslot']

      BetaDeliveryTimeslot.where("time BETWEEN ? AND ?", day.beginning_of_day, day.end_of_day).order("time ASC").each do |timeslot|
        timeslot.beta_orders.each do |beta_order|
          beta_user = beta_order.beta_user
          csv << [beta_order.id, beta_user.name, beta_user.email, beta_order.address1, beta_order.address2, beta_order.state, beta_order.postcode, beta_order.country, beta_order.frame, beta_order.size, beta_order.phone, beta_order.fulfilled, timeslot.time]
        end
      end
    end

    render body:csv_string
  end

  private

  def beta_order_params
    params.permit(:address1, :address2, :state, :postcode, :country, :frame, :size, :phone, :delivery_method).merge(beta_user_id: current_beta_user.id)
  end

end
