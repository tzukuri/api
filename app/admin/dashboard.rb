ActiveAdmin.register_page "Dashboard" do
    menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

    # all orders for the coming week
    next_week = BetaOrder.all_next_week
    next_week_ive_s = next_week.where(frame: 'ive', size: '48')
    next_week_ive_l = next_week.where(frame: 'ive', size: '50.5')
    next_week_ford_s = next_week.where(frame: 'ford', size: '49')
    next_week_ford_l = next_week.where(frame: 'ford', size: '51.5')

    # all orders for the coming month
    next_month = BetaOrder.all_next_month
    next_month_ive_s = next_month.where(frame: 'ive', size: '48')
    next_month_ive_l = next_month.where(frame: 'ive', size: '50.5')
    next_month_ford_s = next_month.where(frame: 'ford', size: '49')
    next_month_ford_l = next_month.where(frame: 'ford', size: '51.5')

    content title: proc{ I18n.t("active_admin.dashboard") } do
        columns do
            column do
                panel "Upcoming Personal Fittings (#{Date.today.strftime("%d-%m")} to #{(Date.today + 7.days).strftime("%d-%m")})" do
                    text_node %{<strong>Total:</strong> #{next_week.count} | <strong>Ive (48mm):</strong> #{next_week_ive_s.count} | <strong>Ive (50.5mm):</strong> #{next_week_ive_l.count} | <strong>Ford (49mm):</strong> #{next_week_ford_s.count} | <strong>Ford (51.5mm):</strong> #{next_week_ford_l.count}}.html_safe
                    table_for next_week.each do
                        column("ID") {|order| link_to order.id}
                        column("Name")   {|order| order.beta_user.name.titleize}
                        column("Email")   {|order| order.beta_user.email}
                        column("Frame")   {|order| order.frame.titleize }
                        column("Size")   {|order| order.size + "mm" }
                        column("Address")   {|order| order.full_address }
                        column("Phone")   {|order| order.phone }
                        column("Delivery Method")   {|order| order.delivery_method.titleize }
                        column("Time")   {|order| order.delivery_time.in_time_zone('Australia/Sydney').strftime("%a %d-%m-%Y %l:%M %P") if order.delivery_time.present?}
                    end
                end

                panel "Upcoming Personal Fittings (#{Date.today.strftime("%d-%m")} to #{(Date.today + 1.month).strftime("%d-%m")})" do
                    text_node %{<strong>Total:</strong> #{next_month.count} | <strong>Ive (48mm):</strong> #{next_month_ive_s.count} | <strong>Ive (50.5mm):</strong> #{next_month_ive_l.count} | <strong>Ford (49mm):</strong> #{next_month_ford_s.count} | <strong>Ford (51.5mm):</strong> #{next_month_ford_l.count}}.html_safe
                    table_for next_month.each do
                        column("ID") {|order| link_to order.id}
                        column("Name")   {|order| order.beta_user.name.titleize}
                        column("Email")   {|order| order.beta_user.email}
                        column("Frame")   {|order| order.frame.titleize }
                        column("Size")   {|order| order.size + "mm" }
                        column("Address")   {|order| order.full_address }
                        column("Phone")   {|order| order.phone }
                        column("Delivery Method")   {|order| order.delivery_method.titleize }
                        column("Time")   {|order| order.delivery_time.in_time_zone('Australia/Sydney').strftime("%a %d-%m-%Y %l:%M %P") if order.delivery_time.present?}
                    end
                end

            end
        end
    end
end
