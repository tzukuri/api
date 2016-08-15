class Feedback < ActiveRecord::Base
  belongs_to :user

  before_validation :decode_attachment_data

  attr_accessor :attachment_data
  has_attached_file :attachment

  validates :topic, presence: true
  validates :content, presence: true

  validates_attachment :attachment, size: {in: 0..10.megabytes},
                            content_type: {content_type: /^image\/(jpeg|png|gif|tiff)$/}

  private

  def decode_attachment_data

    if attachment_data.present?
      data = StringIO.new(Base64.decode64(attachment_data))

      data.class.class_eval {attr_accessor :original_filename, :content_type}
      data.original_filename = id.to_s + ".jpeg"
      data.content_type = "image/jpeg"

      self.attachment = data
    end
  end

end
