Spree::StoreController.class_eval do
  def inject_no_bg_header
    no_bg_pages = ['spree/taxons', 'spree/products', 'spree/orders', 'spree/checkout']
    return 'no-bg' if no_bg_pages.include? params[:controller]
  end

  helper_method :inject_no_bg_header
end
