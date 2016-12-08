class Gift < ActiveRecord::Base
  belongs_to :charge
  has_one :preorder

  validates_presence_of :purchased_by, :expires_at
  validates_uniqueness_of :charge_id, :allow_nil => true
  validates_uniqueness_of :code

  before_validation :generate_gift_code, :set_expires_at, on: :create

  def self.get(code)
    gift = where(code: normalise_code(code)).where("expires_at > ? OR expires_at IS NULL", Time.now).take
    return nil if gift.blank? || gift.redeemed?
    return gift
  end

  def redeemed?
    !preorder.nil?
  end

  private

  INVITE_CODE_LENGTH = 6
  INVITE_MAX_RETRIES = 5

  def generate_gift_code
    self.code = Devise.friendly_token(INVITE_CODE_LENGTH).upcase
    rescue ActiveRecord::RecordNotUnique => e
      @token_attempts = @token_attempts.to_i += 1
      retry if @token_attempts < INVITE_MAX_RETRIES
      raise e, "Retries exhausted, could not find a unique token"
  end

  def set_expires_at
    self.expires_at = 1.year.from_now
  end

  def self.normalise_code(code)
    code.gsub(/\s+/, '').upcase
  end
end
