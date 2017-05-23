module Spree
  class StoreController < Spree::BaseController
    include Spree::Core::ControllerHelpers::Order

    skip_before_action :set_current_order, only: :cart_link

    def forbidden
      render 'spree/shared/forbidden', layout: Spree::Config[:layout], status: 403
    end

    def unauthorized
      render 'spree/shared/unauthorized', layout: Spree::Config[:layout], status: 401
    end

    def cart_link
      render partial: 'spree/shared/link_to_cart'
      fresh_when(simple_current_order)
    end

    def inject_no_bg_header
      no_bg_pages = ['spree/taxons', 'spree/products', 'spree/orders', 'spree/checkout']
      return 'no-bg' if no_bg_pages.include? params[:controller]
    end

    helper_method :inject_no_bg_header

    protected

    def config_locale
      Spree::Frontend::Config[:locale]
    end
  end
end
