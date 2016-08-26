class BetaOrder < ActiveRecord::Base
  belongs_to :beta_user

  validates :beta_user_id,    presence: true, uniqueness: true
  validates :address1,        presence: true
  validates :state,           presence: true
  validates :postcode,        presence: true
  validates :country,         presence: true
  validates :frame,           presence: true
  validates :size,            presence: true
  validates :phone,           presence: true
  validates :delivery_method,  presence: true

  enum delivery_method: [ :ship, :deliver, :meetup ]

  def full_address
    address = address1.titleize + ", " + address2.titleize + ", " + state.upcase + ", " + country.titleize + ", " + postcode
    return address
  end

  def send_confirmation_email
    BetaMailer.send_beta_order_email(self.beta_user).deliver_later
  end

  def valid_delivery?
    delivery_time.present? && booking_id.present? && delivery_method == "deliver"
  end

  # given a start and end time, try to create a booking with timekit
  # this will override any current booking on this object
  # todo: let this delete any existing booking in Timekit (currently unsupported)
  def create_delivery_booking(start_time, end_time)
      event = {
        start: start_time.to_time.iso8601,
        end: end_time.to_time.iso8601,
        what: 'Tzukuri Personal Fitting - ' + beta_user.name,
        where: full_address,
        calendar_id: '348c52b6-ae68-40d3-9781-2ea308505f04',
        description: ''
      }

      customer = {
        name: beta_user.name,
        email: beta_user.email,
        phone: phone,
        voip: '',
        # fixme: assuming that everyone is in Sydney for now
        timezone: 'Australia/Sydney'
      }

      # don't notify the customer by email, we'll send our own confirmation
      notify = {
        enabled: false
      }

      timekit = Tzukuri::Timekit.new("beta@tzukuri.com", 'XAuyu7wMLLjSlF6pltBJR4x8d4W3tN7W')

      begin
        response = timekit.create_booking(event, customer, notify)
        booking = JSON.parse(response.body)
        # set the delivery time and the booking ID now that booking is confirmed
        update_attribute('delivery_time', start_time)
        update_attribute('booking_id', booking["data"]["id"])
      rescue => e
        # todo: handle an error
      end
  end

  def self.all_next_week
    BetaOrder.order('delivery_time asc').where('delivery_time BETWEEN ? AND ?', Date.today.beginning_of_day, (Date.today + 7.days).end_of_day)
  end

  def self.all_next_month
    BetaOrder.order('delivery_time asc').where('delivery_time BETWEEN ? AND ?', Date.today.beginning_of_day, (Date.today + 1.month).end_of_day)
  end

  def self.all_for_week_beginning(date)
    return if !date.is_a?(String)

    start = Date.parse(date.to_s)
    BetaOrder.order('delivery_time asc').where('delivery_time BETWEEN ? AND ?', start.beginning_of_day, (start + 1.week).end_of_day)
  end

  def self.all_for_month_beginning(date)
    return if !date.is_a?(String)

    start = Date.parse(date.to_s)
    BetaOrder.order('delivery_time asc').where('delivery_time BETWEEN ? AND ?', start.beginning_of_day, (start + 1.month).end_of_day)
  end
end
