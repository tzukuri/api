class Enquiry

  include ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :name, :email, :content

  validates :name, presence: true
  
  validates :email, presence: true
  validates_format_of :email,:with => Devise.email_regexp

  validates :content, presence: true

end
