class Preorder < ActiveRecord::Base
    attr_accessor :address1, :address2

    validates :name, presence: true
    validates :phone, presence: true
    validates :customer_id, presence: true
    validates :charge_id, presence: true

    validates :email, presence: true
    validates_format_of :email,:with => Devise::email_regexp

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
      if lens == "prescription"
        total = Tzukuri::PRICING[:prescription] - Tzukuri::PRICING[:deposit]
      elsif lens == "non-prescription"
        total = Tzukuri::PRICING[:non_prescription] - Tzukuri::PRICING[:deposit]
      end

      if code.present?
        total -= Tzukuri::DISCOUNTS[code.to_sym] || 0
      end

      return total
    end
end
