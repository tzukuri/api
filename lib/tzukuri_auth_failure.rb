class TzukuriAuthFailure < Devise::FailureApp
  # return a url that we should redirect to on failure
  def redirect_url

    # if the beta user fails to authenticate, redirect back to the referrer
    if warden_options[:scope] == :beta_user
      request.referrer
    elsif warden_options[:scope] == :user
      new_user_session_path
    elsif warden_options[:scope] == :admin_user
      new_admin_user_session_path
    end
  end

  # respond method decides what action to take
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
