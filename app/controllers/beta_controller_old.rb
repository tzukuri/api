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
      @rank = BetaSignup.order(score: :desc).where(selected: false).index(@beta_signup)
      @invited_by = @beta_signup.invited_by
      @num_invited = @beta_signup.invitees.count
    end
  end

end
