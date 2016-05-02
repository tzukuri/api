# http://daniel.fone.net.nz/blog/2014/12/10/handling-token-generation-collisions-in-activerecord/

class BetaSignup < ActiveRecord::Base
  # before we validate the signup, generate the invite code
  before_validation :generate_invite_code

  # each signup can be invited by at most one person
  belongs_to :invited_by, :class_name => "BetaSignup"
  # each signup can invite 0 or more signups
  has_many :invitees, :class_name => "BetaSignup", :foreign_key => "invited_by_id"

  # must provide an email and a country and each signup gets their own unique invite code
  validates :email, presence: true
  validates :country, presence: true
  validates :invite_code, presence: true

  private

    def generate_invite_code
      # todo: implement logic for generating invite code
      self.invite_code = "<INVITE_CODE>" if self.invite_code == nil;
    end

end
