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

  def full_address
    address = address1.titleize + ", " + address2.titleize + ", " + state.upcase + ", " + country.titleize + ", " + postcode
    return address
  end

  def delivery_timeslot?
    !delivery_timeslot.nil?
  end

end
