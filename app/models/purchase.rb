class Purchase < ActiveRecord::Base
    validates :email, presence: true
    validates :frame, presence: true
    validates :colour, presence: true
    validates :size, presence: true
    validates :customer_id, presence: true
    validates :name, presence: true
    validates :address1, presence: true
    validates :country, presence: true
    validates :postcode, presence: true
end
