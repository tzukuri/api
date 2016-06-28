class BetaResponsesController < ApplicationController

  def create
    puts beta_response_params if Rails.env.development?
    beta_response = BetaResponse.create(beta_response_params.merge(:beta_user_id => current_beta_user.id, :response => params[:commit]))

    if !beta_response.valid?
      render :json => {success: false, errors: beta_response.errors}
      return
    else
      current_beta_user.update_score

       render :json => {
          success: true,
          beta_response: beta_response,
          answerable_questions: current_beta_user.answerable_questions.map(&:id)
       }
    end
  end

  private

  def beta_response_params
    params.require(:beta_response).permit(:beta_question_id)
  end

end
