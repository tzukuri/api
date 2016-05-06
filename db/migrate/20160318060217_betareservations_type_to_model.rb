class BetareservationsTypeToModel < ActiveRecord::Migration
  def change
    remove_column :betareservations, :type
    add_column :betareservations, :model, :string
  end
end
