class BetaController < ApplicationController

  def index
    @invite_code = params["ref"]
    @invited_by = BetaSignup.find_by_invite_code(@invite_code)

    @beta_signup = BetaSignup.new
  end

  def show
    @invite_code = params["invite_code"]

    # only attempt to calculate the rank if the signup exists
    if @beta_signup = BetaSignup.find_by_invite_code(@invite_code)
      @rank = BetaSignup.order(score: :desc).index(@beta_signup)
    end
  end

  def create

  end
end
