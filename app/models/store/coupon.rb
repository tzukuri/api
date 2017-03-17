class Coupon < ActiveRecord::Base
  has_many :preorders

  validates_presence_of :code, :discount, :description
  validates_uniqueness_of :code

  def self.get(code)
    coupon = where(code: normalise_code(code)).where('expires_at > ? OR expires_at IS NULL', Time.now).take
    coupon if !coupon.nil? && coupon.redemptions_remain
  end

  # return an amount (in dollars) after the discount has been applied
  def apply_discount(amount)
    amount - discount
  end

  # the number of times this coupon has been redeemed
  def num_redemptions
    preorders.count
  end

  # returns whether or not this coupon has remaining redemptions
  def redemptions_remain
    max_redemptions.nil? || num_redemptions < max_redemptions
  end

  private

  def self.normalise_code(code)
    code.gsub(/\s+/, '').upcase
  end
end
