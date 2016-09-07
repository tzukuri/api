module Tzukuri
  class Timekit
    include HTTParty
    base_uri 'https://api.timekit.io'
    headers = {
      'Timekit-App' => 'tzukuri',
      'Content-Type' => 'application/json'
    }

    def initialize(user, password)
      @auth = {username: user, password: password}
    end

    def create_booking(event, customer, notify_customer)

      payload = {
        graph: 'instant',
        action: 'confirm',
        event: event,
        customer: customer,
        notify_customer_by_email: notify_customer
      }

      response = HTTParty.post(
        'https://api.timekit.io/v2/bookings',
        :body => JSON.dump(payload),
        :headers => {
          'Timekit-App' => 'tzukuri',
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        },
        :basic_auth => @auth
      )
    end

  end
end
