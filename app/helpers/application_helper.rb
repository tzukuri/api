module ApplicationHelper

  def oauth_path(provider)
    "/beta_users/auth/#{provider.to_s}"
  end

end
