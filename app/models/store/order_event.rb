class OrderEvent < ActiveRecord::Base
  belongs_to :preorder

  validates_presence_of :preorder_id

  validates :name, inclusion: {
    in: ['waiting', 'in_progress', 'shipped'],
    message: "%{value} is not a valid order event type"
  }

  def self.waiting(preorder_id)
    OrderEvent.create(name: 'waiting', preorder_id: preorder_id)
  end

  def self.in_progress(preorder_id)
    return OrderEvent.create(name: 'in_progress', preorder_id: preorder_id)
  end

  def self.shipped(preorder_id)
    return OrderEvent.create(name: 'shipped', preorder_id: preorder_id)
  end
end
