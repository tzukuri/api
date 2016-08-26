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
