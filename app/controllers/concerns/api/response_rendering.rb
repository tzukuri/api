module Api::ResponseRendering
    extend ActiveSupport::Concern

    included do
        # rescue all other exceptions. handlers are checked
        # bottom to top so this handler will be checked last
        rescue_from StandardError do |exception|
            # print exception and add to appsignal
            Rails.logger.warn exception.inspect
            Rails.logger.warn exception.backtrace.join("\n")
            # Appsignal.add_exception(exception)
            payload = response_for_error(:unknown_error)
            render json: payload, status: 500
        end

        # response from call to render_error or render_success
        rescue_from ::Tzukuri::Response do |exception|
            render json: exception.payload, status: exception.status
        end

        # callbacks returned false and prevented save
        rescue_from ActiveRecord::RecordNotSaved do |exception|
            # Appsignal.add_exception(exception)
            payload = response_for_error(:unknown_error)
            render json: payload, status: 400
        end

        # validation failed
        rescue_from ActiveRecord::RecordInvalid do |exception|
            errors = exception.record.errors
            payload = response_for_error(:validation_error, {
                messages: errors.full_messages.uniq.join('. '),
                fields: errors.keys
            })

            render json: payload, status: 400
        end

        # lookup failed. these should be handled by the action,
        # so this is considered an implementation error
        rescue_from ActiveRecord::RecordNotFound do |exception|
            # Appsignal.add_exception(exception)
            payload = response_for_error(:unknown_record)
            render json: payload, status: 404
        end

        # unknown path
        rescue_from ActionController::RoutingError,
                    ActionController::UnknownController,
                    AbstractController::ActionNotFound do
            payload = response_for_error(:unknown_action)
            render json: payload, status: 404
        end
    end

    def render_error(error, other_data = {}, status: 401)
        payload = response_for_error(error, other_data)
        raise Tzukuri::Response.new(payload, status)
    end

    def render_success(other_data = {})
        payload = { success: true }.merge(other_data)
        raise Tzukuri::Response.new(payload, 200)
    end

    private
        def response_for_error(error, other_data = {})
            # Appsignal.increment_counter(error.to_s, 1)
            {
                success: false,
                error: error.to_s,
                description: I18n.t(error.to_s)
            }.merge(other_data)
        end
end
