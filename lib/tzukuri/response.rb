module Tzukuri
    class Response < StandardError
        attr_reader :payload, :status

        def initialize(payload, status)
            @payload = payload
            @status = status
        end
    end
end
