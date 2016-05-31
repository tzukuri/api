class BetaOrder < ActiveRecord::Base
  belongs_to :beta_user

  validates :beta_user_id,  presence: true, uniqueness: true
  validates :address1,      presence: true
  validates :state,         presence: true
  validates :postcode,      presence: true
  validates :country,       presence: true
  validates :frame,         presence: true
  validates :colour,        presence: true
  validates :size,          presence: true
end
