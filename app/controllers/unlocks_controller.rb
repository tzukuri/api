class UnlocksController < Devise::UnlocksController

  protected

  # after the user has been send unlock instructions
  # show them a view that indicates they should check their email
  def after_sending_unlock_instructions_path_for(resource)
    return "/unlock-instructions"
  end

  # after the user has successfully unlocked their account,
  # show them a view that explains that they can now log in to the tzukuri app
  def after_unlock_path_for(resource)
    return "/unlock-success"
  end

end
