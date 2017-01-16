class Quietzone < ActiveRecord::Base
  # every quiet zone must have a user association
  belongs_to  :user
  has_many    :rooms

  # validations
  validates :name,        presence: true,
                          uniqueness: { scope: :user, message: 'must be unique'}
  validates :latitude,    presence: true,
                          numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude,   presence: true,
                          numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :radius,      presence: true
  validates :user_id,     presence: true

  def start_time
    return epoch_time(starttime)
  end

  def end_time
    return epoch_time(endtime)
  end

  private

  def epoch_time(ts)
    return if ts.nil?
    # quietzone timestamps are always stored as UTC
    return Time.at(ts).utc
  end

end
