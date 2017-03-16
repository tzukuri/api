class Preorder < ActiveRecord::Base
    attr_accessor :address1, :address2

    # preorder keeps track of whether or not is used a coupon, a charge or a gift to create it
    belongs_to :coupon
    belongs_to :charge
    belongs_to :gift
    has_many :order_events

    validates_presence_of :name
    validates_presence_of :phone
    validates_presence_of :email
    validates_format_of :email,:with => Devise::email_regexp

    # each charge ID should only have one preorder
    validates_uniqueness_of :charge_id, :allow_nil => true

    # ensure only the charge or the gift ID is set
    validate :charge_or_gift
    validate :prescription_method_if_prescription

    validates :utility, inclusion: {
      in: ['Optical', 'Sun'],
      message: "%{value} is not a valid utility"
    }

    validates :frame, inclusion: {
      in: ['Ive', 'Ford'],
      message: "%{value} is not a valid frame"
    }

    validates :size, inclusion: {
      in: ['48', '49', '51.5'],
      message: "%{value} is not a valid size"
    }

    validates :lens, inclusion: {
      in: ['Prescription', 'Non-Prescription', 'Prescription Reading', 'Prescription Distance'],
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

    def sku
      sku = frame.upcase

      if utility == "Sun"
        sku = sku + "-SU"
      else
        sku = sku + "-OP"
      end

      if frame == "Ford"
        if size == '49'
          sku = sku + "-RE"
        else
          sku = sku + "-LG"
        end
      end

      if lens == "Non-Prescription"
        sku = sku + "-NP"
      else
        sku = sku + "-P"
      end

      return sku
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

    def status
      order_events.empty? ? "" : order_events.last.name
    end

    def last_event
      order_events.empty? ? nil : order_events.last
    end

    def events
      order_events
    end

    def self.in_progress
      Preorder.all.select{|p| p.status == "in_progress"}
    end

    def self.waiting
      Preorder.all.select{|p| p.status == "waiting" }
    end

    private

    def charge_or_gift
      unless charge_id.blank? || gift_id.blank?
        errors.add(:base, "Specify a charge or gift, not both")
      end
    end

    # only require a prescription method if the prescription is present
    def prescription_method_if_prescription
      puts lens
      puts prescription_method

      if (lens == "Prescription" || lens == "Prescription Reading" || lens == "Prescription Distance")
        if (prescription_method != "I will email it to hello@tzukuri.com" && prescription_method != "Please call me to discuss")
          puts 'adding error'
          errors.add(:base, "Prescription requires a prescription method")
        end
      end
    end

end
