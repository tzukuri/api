class Api::V0::FeedbacksController < Api::ApiController
    before_action :log_in_with_auth_token

    def create
        @feedback = Feedback.create(feedback_params)
        @feedback.user = @user
        @feedback.save!
    end

    private

    def feedback_params
        params.permit(:topic, :content, :attachment_data)
    end
end
