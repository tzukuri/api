ActiveAdmin.register Preorder do
    menu parent: 'Sales'

    index do
      selectable_column
      id_column
      column :name
      column :email
      column :phone
      column :address do |preorder|
         "#{preorder.address_lines.join(', ')}, #{preorder.state}, #{preorder.postal_code}"
      end
      column :utility do |preorder|
        preorder.utility.titleize
      end
      column :frame do |preorder|
        preorder.frame.titleize
      end
      column :size do |preorder|
        "#{preorder.size}mm"
      end
      column :lens do |preorder|
        preorder.lens.titleize
      end
      column :engraving do |preorder|
        if preorder.gift?
          preorder.gift.engraving
        end
      end
      column :order_date do |preorder|
        preorder.created_at.in_time_zone('Australia/Sydney').strftime("%d/%m/%Y")
      end
      column :amount do |preorder|
        preorder.charge.amount/100 if preorder.charge?
      end
      column :coupon do |preorder|
        preorder.coupon? ? status_tag("YES") : status_tag("NO")
      end
      column :gift do |preorder|
        preorder.gift? ? status_tag("YES") : status_tag("NO")
      end
    end
end
