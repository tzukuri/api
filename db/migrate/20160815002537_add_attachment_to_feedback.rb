class AddAttachmentToFeedback < ActiveRecord::Migration
  def change
    add_attachment :feedbacks, :attachment
  end
end
