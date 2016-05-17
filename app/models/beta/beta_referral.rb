class BetaReferral < ActiveRecord::Base
  # an invitee should be unique as an invitee can only be invited by exactly one other user
  validates :invitee_id, uniqueness: true, presence: true
  validates :inviter_id, presence: true

  belongs_to :inviter, :class_name => "BetaUser"
  belongs_to :invitee, :class_name => "BetaUser"

  # create a beta referral given an invitee id and an inviter token
  def self.create_for(invitee_id, inviter_token)
    inviter_id = BetaUser.find_by_invite_token(inviter_token).id
    BetaReferral.create!(inviter_id: inviter_id, invitee_id: invitee_id)
  end
end
