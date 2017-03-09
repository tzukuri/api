class Lead < ActiveRecord::Base
    validates :email, presence: true
    validates :ip, presence: true
end
