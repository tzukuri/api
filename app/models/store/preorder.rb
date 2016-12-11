class Preorder < ActiveRecord::Base
    attr_accessor :address1, :address2

    # preorder keeps track of whether or not is used a coupon, a charge or a gift to create it
    belongs_to :coupon
    belongs_to :charge
    belongs_to :gift

    validates_presence_of :name
    validates_presence_of :phone
    validates_presence_of :email
    validates_format_of :email,:with => Devise::email_regexp

    # each charge ID should only have one preorder
    validates_uniqueness_of :charge_id, :allow_nil => true

    # ensure only the charge or the gift ID is set
    validate :charge_or_gift

    validates :utility, inclusion: {
      in: ['optical', 'sun'],
      message: "%{value} is not a valid utility"
    }

    validates :frame, inclusion: {
      in: ['ive', 'ford'],
      message: "%{value} is not a valid frame"
    }

    validates :size, inclusion: {
      in: ['48', '49', '51.5'],
      message: "%{value} is not a valid size"
    }

    validates :lens, inclusion: {
      in: ['prescription', 'non-prescription'],
      message: "%{value} is not a valid lens type"
    }

    def formatted_address
      address_lines.push(state, country, postal_code).join(", ")
    end

    def formatted_item
      [utility.titleize, frame.titleize, lens.titleize, size + "mm"].join(" | ")
    end

    def send_confirmation
      StoreMailer.preorder_confirmation(self).deliver_later
    end

    def gift?
      !gift.nil?
    end

    def charge?
      !charge.nil?
    end

    def coupon?
      !coupon.nil?
    end

    private

    def charge_or_gift
      unless charge_id.blank? || gift_id.blank?
        errors.add(:base, "Specify a charge or gift, not both")
      end
    end

end
