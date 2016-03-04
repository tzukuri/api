class Recording < ActiveRecord::Base

  # each recording belongs to a device and a room
  belongs_to :device
  belongs_to :room

  # validations
  validates :device_id,         presence: true
  validates :room_id,           presence: true
  validates :recording_date,    presence: true
end
