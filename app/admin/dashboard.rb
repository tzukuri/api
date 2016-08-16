ActiveAdmin.register_page "Dashboard" do
    menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

    next_week = BetaOrder.all_next_week
    next_month = BetaOrder.all_next_month

    content title: proc{ I18n.t("active_admin.dashboard") } do
        columns do
            column do
                panel "Upcoming Personal Fittings (#{Date.today.strftime("%d-%m")} to #{(Date.today + 7.days).strftime("%d-%m")})" do
                    text_node %{<strong>Total:</strong> #{next_week.count}}.html_safe
                    table_for next_week.each do
                        column("ID") {|order| link_to order.id}
                        column("Name")   {|order| order.beta_user.name.titleize}
                        column("Email")   {|order| order.beta_user.email}
                        column("Frame")   {|order| order.frame.titleize }
                        column("Size")   {|order| order.size + "mm" }
                        column("Address")   {|order| order.full_address }
                        column("Phone")   {|order| order.phone }
                        column("Delivery Method")   {|order| order.delivery_method.titleize }
                        column("Time")   {|order| order.beta_delivery_timeslot.time.strftime("%a %d-%m-%Y %H:%M %P") if order.beta_delivery_timeslot.present? }
                    end
                end

                panel "Upcoming Personal Fittings (#{Date.today.strftime("%d-%m")} to #{(Date.today + 1.month).strftime("%d-%m")})" do
                    text_node %{<strong>Total:</strong> #{next_month.count}}.html_safe
                    table_for next_month.each do
                        column("ID") {|order| link_to order.id}
                        column("Name")   {|order| order.beta_user.name.titleize}
                        column("Email")   {|order| order.beta_user.email}
                        column("Frame")   {|order| order.frame.titleize }
                        column("Size")   {|order| order.size + "mm" }
                        column("Address")   {|order| order.full_address }
                        column("Phone")   {|order| order.phone }
                        column("Delivery Method")   {|order| order.delivery_method.titleize }
                        column("Time")   {|order| order.beta_delivery_timeslot.time.strftime("%a %d-%m-%Y %H:%M %P") if order.beta_delivery_timeslot.present? }
                    end
                end

            end
        end


        # Here is an example of a simple dashboard with columns and panels.
        #
        # columns do
        #   column do
        #     panel "Recent Posts" do
        #       ul do
        #         Post.recent(5).map do |post|
        #           li link_to(post.title, admin_post_path(post))
        #         end
        #       end
        #     end
        #   end

        #   column do
        #     panel "Info" do
        #       para "Welcome to ActiveAdmin."
        #     end
        #   end
        # end
    end # content
end
