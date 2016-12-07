class Charge < ActiveRecord::Base
  has_one :preorder

  validates_presence_of :charge_id, :customer_id, :amount
end
