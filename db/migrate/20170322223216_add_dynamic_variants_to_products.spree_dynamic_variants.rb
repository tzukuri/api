# This migration comes from spree_dynamic_variants (originally 20151026230300)
class AddDynamicVariantsToProducts < ActiveRecord::Migration

  def change
    add_column :spree_products, :dynamic_variants, :boolean, :default => false
  end

end
