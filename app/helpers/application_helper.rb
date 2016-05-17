module ApplicationHelper

  # helper for getting the oauth path (provider can be twitter/facebook/instagram)
  def oauth_path(provider)
    "/beta_users/auth/#{provider.to_s}"
  end

end
