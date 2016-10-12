class Preorder < ActiveRecord::Base
    attr_accessor :address1, :address2

    validates :name, presence: true
    validates :email, presence: true
    validates :phone, presence: true
    validates :utility, presence: true
    validates :frame, presence: true
    # validates :size, presence: true
    validates :lens, presence: true
    validates :customer_id, presence: true
    validates :charge_id, presence: true
end
