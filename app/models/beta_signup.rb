class BetaSignup < ActiveRecord::Base
  INVITE_CODE_LENGTH = 6

  # before we validate the signup, generate the invite code
  before_validation :generate_invite_code, on: :create
  after_create :send_confirmation_email
  after_save :check_for_selected

  # each signup can be invited by at most one person
  belongs_to :invited_by, :class_name => "BetaSignup"
  # each signup can invite 0 or more signups
  has_many :invitees, :class_name => "BetaSignup", :foreign_key => "invited_by_id"

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :country, presence: true
  validates :invite_code, presence: true,  uniqueness: true, :length => { :is => INVITE_CODE_LENGTH }
  validates :score, presence: true
  validates :birth_date, presence: true

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

    def check_for_selected
      if changes[:selected] && self.selected == true
        # send a beta acceptance email
        BetaMailer.send_beta_acceptance_email(self).deliver
      end
    end

    def send_confirmation_email
      BetaMailer.send_beta_confirmation_email(self).deliver
    end

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
