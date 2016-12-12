ActiveAdmin.register_page "Dashboard" do
    menu label: "General", parent: 'Dashboards'

    content title: "General"  do

      cutoff = Date.parse('12/12/2016')
      orders = Preorder.where('created_at <= ?', cutoff).reverse

      panel "Upcoming Orders (Placed on or before #{cutoff.strftime("%d/%m/%y")})" do
        text_node %{<strong>Upcoming Orders:</strong> #{orders.count} | <strong>Total Orders:</strong> #{Preorder.all.count}}.html_safe
        table_for orders.each do
          column("ID") {|preorder| link_to preorder.id}
          column("Name") {|preorder| preorder.name}
          column("Email") {|preorder| preorder.email}
          column("Shipping Address") {|preorder| "#{preorder.address_lines.join(', ')}, #{preorder.state}, #{preorder.postal_code}"}
          column("Utility") {|preorder| preorder.utility.titleize}
          column("Frame") {|preorder| preorder.frame.titleize}
          column("Lens") {|preorder| preorder.lens.titleize}
          column("Size") {|preorder| "#{preorder.size}mm"}
          column("Gift") {|preorder| preorder.gift? ? status_tag("YES") : status_tag("NO")}
        end
      end
    end
end
