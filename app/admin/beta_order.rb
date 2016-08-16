ActiveAdmin.register BetaOrder do
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
        column :frame
        column :size
        column :phone
        column :delivery_method
        column :fulfilled
        column :timeslot do |order|
            if (order.beta_delivery_timeslot.present?)
              order.beta_delivery_timeslot.time.strftime("%a %d-%m-%Y %H:%M %P")
            else
                "N/A"
            end
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
            f.input :beta_delivery_timeslot do |timeslot|
                auto_link timeslot.time
            end
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
