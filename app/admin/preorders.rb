ActiveAdmin.register Preorder do
    menu parent: 'Sales'

    index do

      div :class => "row", :style => "margin-bottom: 20px; margin-top: 30px;" do
        div :class => "three columns", :style => "text-align: center; border: 1px solid black; padding-top: 15px; clear: none" do
          h1 Preorder.all.count
          h3 "Total Preorders"
        end
        div :class => "three columns", :style => "text-align: center; border: 1px solid black; padding-top: 15px; clear: none" do
          h1 Gift.all.count
          h3 "Total Gifts"
        end
        div :class => "three columns", :style => "text-align: center; border: 1px solid black; padding-top: 15px; clear: none" do
          h1 Preorder.where(lens: 'prescription').count
          h3 "Prescription"
        end
        div :class => "three columns", :style => "text-align: center; border: 1px solid black; padding-top: 15px; clear: none" do
          h1 Preorder.where(lens: 'non-prescription').count
          h3 "Non-Prescription"
        end
      end

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
      column :status do |preorder|
        if preorder.status == "in_progress"
          status_tag preorder.status, :warn
        elsif preorder.status == "shipped"
          status_tag preorder.status, :ok
        else
          status_tag preorder.status
        end
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


    # batch actions
    # batch_action :wait do |ids|
    #   Preorder.find(ids).each do |preorder|
    #     OrderEvent.waiting(preorder.id)
    #   end
    #
    #   redirect_to collection_path, alert: "#{ids.count} orders flagged as waiting"
    # end
    #
    # batch_action :begin do |ids|
    #   Preorder.find(ids).each do |preorder|
    #     OrderEvent.in_progress(preorder.id)
    #   end
    #
    #   redirect_to collection_path, alert: "#{ids.count} orders flagged as in progress"
    # end
end
