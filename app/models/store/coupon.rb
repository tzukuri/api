class Coupon < ActiveRecord::Base
  has_many :preorders

  validates_presence_of :code, :discount
  validates_uniqueness_of :code

  def self.get(code)
    where(code: normalise_code(code)).where('expires_at > ? OR expires_at IS NULL', Time.now).take
  end

  # return an amount (in dollars) after the discount has been applied
  def apply_discount(amount)
    amount - discount
  end

  private

  def self.normalise_code(code)
    code.gsub(/\s+/, '').upcase
  end
end
