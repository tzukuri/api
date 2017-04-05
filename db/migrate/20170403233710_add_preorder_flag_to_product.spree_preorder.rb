# This migration comes from spree_preorder (originally 20170403233100)
class AddPreorderFlagToProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :preorder, :boolean, :default => false
  end
end
