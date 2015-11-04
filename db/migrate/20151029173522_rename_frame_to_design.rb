class RenameFrameToDesign < ActiveRecord::Migration
    def change
        rename_column :devices, :frame, :design
    end
end
