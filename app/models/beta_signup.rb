# http://daniel.fone.net.nz/blog/2014/12/10/handling-token-generation-collisions-in-activerecord/

class BetaSignup < ActiveRecord::Base
  INVITE_CODE_LENGTH = 6

  # before we validate the signup, generate the invite code
  before_validation :generate_invite_code, on: :create

  # each signup can be invited by at most one person
  belongs_to :invited_by, :class_name => "BetaSignup"
  # each signup can invite 0 or more signups
  has_many :invitees, :class_name => "BetaSignup", :foreign_key => "invited_by_id"

  # must provide an email and a country and each signup gets their own unique invite code
  validates :email, presence: true
  validates :country, presence: true
  validates :invite_code, presence: true, :length => { :is => INVITE_CODE_LENGTH }

  # enforce email regex
  validates_format_of :email,:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  private
    INVITE_MAX_RETRIES = 5

    def generate_invite_code
      self.invite_code = SecureRandom.hex(INVITE_CODE_LENGTH/2)
    rescue
      @token_attempts = @token_attempts.to_i += 1
      retry if @token_attempts < INVITE_MAX_RETRIES
      raise e, "Retried exhausted, could not find a unique token"
    end

end
