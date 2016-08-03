class RemoveAndChangeStartAndEndTimeTypes < ActiveRecord::Migration
    def change
        remove_column :quietzones, :starttime
        remove_column :quietzones, :endtime
        add_column :quietzones, :starttime, :integer
        add_column :quietzones, :endtime, :integer
    end
end
