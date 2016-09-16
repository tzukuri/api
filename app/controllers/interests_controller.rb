class InterestsController < ApplicationController

  def create
    interest = Interest.create(interest_params)

    if !interest.valid?
      render json: {success: false, errors: interest.errors}
      return
    end

    render json: {success: true, interest: interest}
  end

  private

  def interest_params
    params.require(:interest).permit(:name, :email, :city, :country)
  end
end
