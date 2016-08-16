class BetaOrder < ActiveRecord::Base
  belongs_to :beta_user
  belongs_to :beta_delivery_timeslot

  validates :beta_user_id,    presence: true, uniqueness: true
  validates :address1,        presence: true
  validates :state,           presence: true
  validates :postcode,        presence: true
  validates :country,         presence: true
  validates :frame,           presence: true
  validates :size,            presence: true
  validates :phone,           presence: true
  validates :delivery_method,  presence: true
  validates_associated :beta_delivery_timeslot

  enum delivery_method: [ :ship, :deliver, :meetup ]

  after_create      :send_confirmation_email

  def full_address
    address = address1.titleize + ", " + address2.titleize + ", " + state.upcase + ", " + country.titleize + ", " + postcode
    return address
  end

  def delivery_timeslot?
    !delivery_timeslot.nil?
  end

  def send_confirmation_email
    BetaMailer.send_beta_order_email(self.beta_user).deliver_later
  end

  def self.all_next_week
    today = Date.today
    endDay = today + 7.days

    orders = []

    BetaOrder.all.each do |order|
      next if !order.beta_delivery_timeslot.present?
      orders.push(order) if (today..endDay).cover?(order.beta_delivery_timeslot.time)
    end

    return orders
  end

  def self.all_next_month
    today = Date.today
    endDay = today + 1.month

    orders = []

    BetaOrder.all.each do |order|
      next if !order.beta_delivery_timeslot.present?
      orders.push(order) if (today..endDay).cover?(order.beta_delivery_timeslot.time)
    end

    return orders

  end

end
