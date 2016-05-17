class MyAuthFailure < Devise::FailureApp
  # def redirect_url

  #   puts warden_options[:scope]

  #   if warden_options[:scope] == :beta_user
  #     # todo: probably do this some better way
  #     '/beta/' + params[:beta_user][:invite_token]
  #   elsif warden_options[:scope] == :user
  #     new_user_session_path
  #   end
  # end
  #


  # You need to override respond to eliminate recall
  # def respond
  #   if http_auth?
  #     http_auth
  #   else
  #     redirect
  #   end
  # end

end
