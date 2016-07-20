class BetaDeliveryTimeslot < ActiveRecord::Base
  belongs_to :beta_order

  validates :timeslot, presence: true

  # returns true if this timeslot has been assigned to someone
  def assigned?
    !beta_order_id.nil?
  end

end
