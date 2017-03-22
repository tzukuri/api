# This migration comes from spree_api (originally 20120530054546)
class RenameApiKeyToSpreeApiKey < ActiveRecord::Migration
  def change
    # unless defined?(Spree::User)
      rename_column :spree_users, :api_key, :spree_api_key
    # end
  end
end
