ActiveAdmin.register BetaOrder do
    menu parent: 'Beta'

    permit_params :address1, :address2, :state, :postcode, :frame, :size, :phone, :delivery_method, :fulfilled

    index do
        selectable_column
        id_column
        column :name do |order|
            auto_link order.beta_user.name
        end
        column :email do |order|
            auto_link order.beta_user.email
        end
        column :address do |order|
            order.full_address
        end
        column :frame do |order|
            order.frame.titleize
        end
        column :size
        column :phone
        column :delivery_method
        column :fulfilled
        column :delivery_time do |order|
            order.delivery_time.in_time_zone('Australia/Sydney').strftime("%a %d-%m-%Y %l:%M %P") if order.delivery_time.present?
        end
        actions
    end


    form do |f|
        f.inputs "Beta Order Details" do
            f.input :beta_user
            f.input :address1
            f.input :address2
            f.input :state
            f.input :postcode
            f.input :frame
            f.input :size
            f.input :delivery_method
            f.input :delivery_time
            f.input :fulfilled
        end
        f.actions
    end

    filter :state
    filter :postcode
    filter :frame
    filter :size
    filter :delivery_method
    filter :fulfilled
end
