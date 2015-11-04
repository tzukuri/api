class App < ActiveRecord::Base
    validates :name, presence: true
end
