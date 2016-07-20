class BetaOrder < ActiveRecord::Base
  belongs_to :beta_user
  has_one :delivery_timeslot, :foreign_key => 'beta_order_id', :class_name => 'BetaDeliveryTimeslot'

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

  def delivery_timeslot?
    !delivery_timeslot.nil?
  end
end
