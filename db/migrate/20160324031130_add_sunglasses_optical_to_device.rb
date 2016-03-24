class AddSunglassesOpticalToDevice < ActiveRecord::Migration
  def change
      add_column :devices, :optical, :boolean
  end
end
