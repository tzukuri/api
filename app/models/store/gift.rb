class Gift < ActiveRecord::Base
  belongs_to :charge
  has_one :preorder

  validates_uniqueness_of :charge_id, :allow_nil => true
end
