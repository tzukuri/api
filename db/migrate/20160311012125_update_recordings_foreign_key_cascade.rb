class UpdateRecordingsForeignKeyCascade < ActiveRecord::Migration
  def change
    remove_foreign_key :recordings, :rooms
    add_foreign_key :recordings, :rooms, on_delete: :cascade
  end
end
