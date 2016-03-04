class Recording < ActiveRecord::Base
  # this has data attached to it
  has_attached_file :data

  # each recording belongs to a device and a room
  belongs_to :device
  belongs_to :room

  # validations
  validates :device_id,                    presence: true
  validates :room_id,                      presence: true
  validates :recording_date,               presence: true
  validates :data,                         :attachment_presence => true

  # TODO: update this to use the real data type if it's different
  validates_attachment_content_type :data, content_type: "text/plain"


end
