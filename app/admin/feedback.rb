ActiveAdmin.register Feedback do
    menu parent: 'beta'

    permit_params :topic, :content, :attachment_file_name

    index do
        selectable_column
        id_column
        column :topic
        column :content
        column :attachment_file_name
        actions
    end

end
