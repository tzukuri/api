class BetaReferral < ActiveRecord::Base
  belongs_to :inviter, :class_name => "BetaUser"
  belongs_to :invitee, :class_name => "BetaUser"

  # an invitee should be unique as an invitee can only be invited by exactly one other user
  validates :invitee_id, uniqueness: true, presence: true
  validates :inviter_id, presence: true
end
