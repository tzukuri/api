class Gift < ActiveRecord::Base
  attr_accessor :coupon

  # gift keeps track of the charge_id
  belongs_to :charge
  # preorder keeps track of whether or not it has a gift
  has_one :preorder

  # requires a purchased_by email, expiry date and code
  # doesn't require a charge_id as we generally need to wait for a call to Stripe
  validates_presence_of :purchased_by, :expires_at, :code
  validates_format_of :purchased_by,:with => Devise::email_regexp
  validates_uniqueness_of :charge_id, :allow_nil => true
  validates_uniqueness_of :code
  validates_length_of :engraving, :maximum => 15, :allow_blank => true

  # automatically generate a gift code and set expiry to a year from now on create
  before_validation :generate_gift_code, :set_expires_at, on: :create

  # returns a gift object for a code if it is not redeemed and not expired
  def self.get(code)
    gift = where(code: normalise_code(code)).where("expires_at > ? OR expires_at IS NULL", Time.now).take
    return nil if gift.blank? || gift.redeemed?
    return gift
  end

  def redeemed?
    !preorder.nil?
  end

  def send_confirmation
    StoreMailer.gift_confirmation(self).deliver_later
  end

  def send_redeemed
    StoreMailer.gift_redeemed(self).deliver_later
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
