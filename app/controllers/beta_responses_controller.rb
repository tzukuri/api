class BetaResponsesController < ApplicationController

  def create
    @beta_response = BetaResponse.create(
      beta_user_id: current_beta_user.id,
      beta_question_id: beta_response_params[:question_id],
      response: beta_response_params[:response]
    )

    if !@beta_response.valid?
      render :json => {success: false, errors: @beta_response.errors}
      return
    end

    # update the score for creating a response
    points = BetaQuestion.find_by(id: beta_response_params[:question_id]).point_value
    current_beta_user.update_score(points)

    if @beta_response.save
      render :json => {success: true, beta_response: @beta_response}
    else
      render :json => {success: false, errors: @beta_response.errors}
    end
  end

  private

  # required parameters out of the params object
  def beta_response_params
    params.require(:beta_response).permit(:question_id, :response)
  end


end
