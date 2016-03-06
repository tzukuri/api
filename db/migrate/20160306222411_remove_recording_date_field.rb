class RemoveRecordingDateField < ActiveRecord::Migration
  def change
    remove_column :recordings, :date
  end
end
