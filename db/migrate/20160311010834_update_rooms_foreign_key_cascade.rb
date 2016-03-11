class UpdateRoomsForeignKeyCascade < ActiveRecord::Migration
  def change
    # remove the current foreign key, and re-add a new one that will cascade deletes
    remove_foreign_key :rooms, :quietzones
    add_foreign_key :rooms, :quietzones, on_delete: :cascade
  end
end
