ActiveAdmin.register Lead do
    menu parent: 'Sales', priority: 1

    index do
        selectable_column
        column :email
        column :ip
        column :date do |lead|
            lead.created_at.in_time_zone('Australia/Sydney').strftime("%d/%m/%Y %H:%M:%S")
        end
        actions
    end

    controller do
        def index
            params[:order] ||= 'created_at_desc'
            super
        end
    end
end
