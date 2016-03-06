class ChangeRecordingToDatetime < ActiveRecord::Migration
  def change
    remove_column :recordings, :recording_date
    add_column :recordings, :recording_date, :datetime
  end
end
