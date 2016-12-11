class InterestsController < ApplicationController

  def create
    interest = Interest.create(interest_params)

    if !interest.valid?
      render json: {success: false, errors: interest.errors, full_errors: interest.errors.full_messages}
      return
    end

    render json: {success: true, interest: interest}
  end

  private

  def interest_params
    params.require(:interest).permit(:name, :email, :city, :country)
  end
end
