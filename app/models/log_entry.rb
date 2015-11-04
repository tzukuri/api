class LogEntry < ActiveRecord::Base
    belongs_to :auth_token
    validates  :auth_token_id, presence: true
    validates  :type, presence: true
end
