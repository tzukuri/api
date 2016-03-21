class Betareservation < ActiveRecord::Base
  validates :email, presence: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  validates :frame, presence: true
  validates :colour, presence: true
  validates :size, presence: true
  validates :model, presence: true
  validates :name, presence: true
  validates :address1, presence: true
  validates :country, presence: true
  validates :postcode, presence: true
  validates :state, presence: true

end
