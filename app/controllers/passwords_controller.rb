class PasswordsController < Devise::PasswordsController

  protected

  # after the user has requested their reset password instructions
  # redirect them to a page that instructs them to check their email
  def after_sending_reset_password_instructions_path_for(resource_name)
    return "/password-instructions"
  end

  # after the user has successfully reset their password show them a page
  # showing that the reset was successful
  def after_resetting_password_path_for(resource_name)
    return "/password-success"
  end

end
