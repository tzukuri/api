class QuietzonesCanBeAlwaysActive < ActiveRecord::Migration
    def change
        add_column :quietzones, :always_active, :boolean
    end
end
