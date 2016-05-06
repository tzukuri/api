class BetaSignup < ActiveRecord::Base
  INVITE_CODE_LENGTH = 6

  # before we validate the signup, generate the invite code
  before_validation :generate_invite_code, on: :create

  #todo: on create send an email to the user confirming their registration

  # each signup can be invited by at most one person
  belongs_to :invited_by, :class_name => "BetaSignup"
  # each signup can invite 0 or more signups
  has_many :invitees, :class_name => "BetaSignup", :foreign_key => "invited_by_id"

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :country, presence: true
  validates :invite_code, presence: true,  uniqueness: true, :length => { :is => INVITE_CODE_LENGTH }
  validates :score, presence: true

  # enforce email regex
  validates_format_of :email,:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  # invites another user and increments both scores
  def invite(invitee)
    invitee.invited_by = self
    invitee.score += 1
    invitee.save

    self.score += 1
    self.save
  end

  private
    INVITE_MAX_RETRIES = 5

    # generate an invite code of INVITE_CODE_LENGTH
    # will try up to INVITE_MAX_RETRIES times if a generated token is not unieq
    def generate_invite_code
      self.invite_code = SecureRandom.hex(INVITE_CODE_LENGTH/2)
    rescue ActiveRecord::RecordNotUnique => e
      @token_attempts = @token_attempts.to_i += 1
      retry if @token_attempts < INVITE_MAX_RETRIES
      raise e, "Retried exhausted, could not find a unique token"
    end

end
