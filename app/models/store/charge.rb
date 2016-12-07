class Charge < ActiveRecord::Base
  has_one :preorder
  has_one :gift

  validates_presence_of :charge_id, :customer_id, :amount
end
