ActiveAdmin.register Coupon do
    permit_params :code, :discount, :description, :max_redemptions, :expires_at
    actions :index, :show, :new, :create, :update, :edit, :testing
    menu parent: 'Sales'

    action_item :create_preorder_coupon, only: :index do
      link_to 'Generate Preorder Coupon', create_preorder_coupon_admin_coupons_path
    end

    index do
      selectable_column
      id_column
      column :code
      column :discount do |coupon|
        "$#{coupon.discount/100}"
      end
      column :description
      column :num_redemptions
      column :expires_at do |coupon|
        coupon.expires_at? ? coupon.expires_at : status_tag("NEVER")
      end
      column :max_redemptions do |coupon|
        coupon.max_redemptions? ? coupon.max_redemptions : status_tag("NONE")
      end
      actions
    end

    # generate a coupon for a preorder customer. expires 3 months from today
    collection_action :create_preorder_coupon do
      code = "PRE-" + rand.to_s[2..5]
      Coupon.create(code: code, discount: 20000, description: 'A single-use coupon for a 2014 preorder customer', max_redemptions: 1, expires_at: 3.months.from_now)
      redirect_to collection_path, notice: "Pre-order coupon created successfully!"
    end

end
