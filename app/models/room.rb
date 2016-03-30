class Room < ActiveRecord::Base
  # every room must be associated with a quietzone
  belongs_to :quietzone

  # validations
  validates :name,             presence: true,
                                uniqueness: { scope: :quietzone, message: 'room names should be unique for each quietzone'}

  validates :quietzone_id,     presence: true

end
