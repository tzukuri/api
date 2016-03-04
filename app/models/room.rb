class Room < ActiveRecord::Base
  # every room must be associated with a quietzone
  belongs_to :quietzone

  # validations
  validates :name,             presence: true
  validates :quietzone_id,     presence: true

end
