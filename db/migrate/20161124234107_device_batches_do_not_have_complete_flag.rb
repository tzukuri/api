class DeviceBatchesDoNotHaveCompleteFlag < ActiveRecord::Migration
  def change
    remove_column :device_batches, :complete
  end
end
