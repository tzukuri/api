# This migration comes from spree_prescription (originally 20170329050510)
class AddAcceptsPrescriptionToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :accepts_prescription, :boolean, :default => false
  end
end
