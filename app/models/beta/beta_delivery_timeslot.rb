class BetaDeliveryTimeslot < ActiveRecord::Base
  has_many :beta_orders

  validates :time, presence: true
  # each timeslot can have at most 3 orders referencing it
  validate :order_count_within_bounds, :on => :create

  # return a hash that maps each day -> all the available timeslots for that day
  def self.all_timeslots
    end_date = Date.parse("5/08/2016")
    tomorrow = Date.tomorrow
    num_days = (end_date - tomorrow).to_i

    timeslots = {}

    # put each timeslot in a bucket for that day
    for i in 0..num_days
      day = tomorrow + i
      # todo: filter out timeslots that are unavailable
      timeslots[day] = BetaDeliveryTimeslot.where('time BETWEEN ? AND ?', day.beginning_of_day, day.end_of_day).order("time ASC")
    end

    return timeslots
  end

  # returns true if this timeslot has been assigned to at least one order
  def assigned?
    beta_orders.size > 0
  end

  # return true if there are less than three orders referencing it
  def available?
    beta_orders.size < 3
  end

  private

  def order_count_within_bounds
    errors.add('too many orders for this timeslot') if beta_orders.size >= 3
  end

end
