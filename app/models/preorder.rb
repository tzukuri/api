class Preorder < ActiveRecord::Base
    attr_accessor :address1, :address2

    belongs_to :coupon
    belongs_to :charge

    validates_presence_of :name
    validates_presence_of :phone
    validates_presence_of :email
    validates_format_of :email,:with => Devise::email_regexp

    # each charge ID should only have one preorder
    validates_uniqueness_of :charge_id, :allow_nil => true

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

    def amount_remaining
      total - Tzukuri::PRICING[:deposit]
    end

    def total
      if lens == "prescription"
        total = Tzukuri::PRICING[:prescription]
      elsif lens == "non-prescription"
        total = Tzukuri::PRICING[:non_prescription]
      end

      if code.present?
        total -= Tzukuri::DISCOUNTS[code.to_sym] || 0
      end

      return total
    end

    def formatted_address
      address_lines.push(state, country, postal_code).join(", ")
    end

    def formatted_item
      [utility.titleize, frame.titleize, size + "mm", lens.titleize].join(", ")
    end

    def send_confirmation
      StoreMailer.preorder_confirmation(self).deliver_later
    end
end
