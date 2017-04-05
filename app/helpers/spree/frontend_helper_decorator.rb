module Spree
  module FrontendHelper

    def link_to_cart(text = nil)
      text = text ? h(text) : Spree.t('cart')
      css_class = nil

      if simple_current_order.nil? or simple_current_order.item_count.zero?
        text = "<i class='pe-7f-cart'></i>"
        css_class = 'empty'
      else
        text = "<i class='pe-7f-cart'></i> #{simple_current_order.item_count}"
        css_class = 'full'
      end

      link_to text.html_safe, spree.cart_path, class: "cart-info #{css_class}"
    end

  end
end
