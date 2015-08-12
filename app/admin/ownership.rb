ActiveAdmin.register Ownership do
    permit_params :user_id, :device_id, :revoked, :reason

    index do
        selectable_column
        id_column
        column :user_id
        column :device_id
        column :revoked
        actions
    end

    filter :user_id
    filter :device_id
    filter :revoked

    form do |f|
        f.inputs "Ownership Details" do
            f.input :user
            f.input :device
            f.input :revoked, as: :datepicker
            f.input :reason
        end
        f.actions
    end
end
