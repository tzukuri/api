class AddAttachmentToRecording < ActiveRecord::Migration
  def change
    add_attachment :recordings, :data
  end
end
