class PagesController < ApplicationController
    def index

        meta = {
          index: {title: "Beautifully Handmade Glasses You Won't Lose", description: "Have you ever lost a pair of valuable glasses or sunglasses? Not any more. Introducing Tzukuri the world's first unlosable glasses. Try them on today."},
          unlosable_glasses: {title: "Beautifully Handmade Glasses You Won't Lose", description: "The Tzukuri iPhone app notifies you if you leave your glasses behind, remembers where you last left them and calculates the distance to them."},
          the_range: {title: "The Range", description: "Beautifully designed optical, sunglasses or optical sunglasses, supremely balanced for comfort and style. Try them on today."},
          intelligently_made: {title: "Intelligently Made", description: "Made from a high optical clarity polymer half the weight of glass together with an integrated rechargeable battery. Try them on today"},
          book_try_on: {title: "Book your Tzukuri Personal Try On", description: "Choosing glasses without trying them on is difficult. To make it easier, we'll bring them to your office, home or local cafe."},
          team: {title: "Team", description: ""},
          buy: {title: "Purchase Unlosable Glasses", description: ""},
          contact_us: {title: "Contact Us", description: ""},
          privacy: {title: "Privacy Policy", description: ""},
          retail: {title: "Tzukuri Sydney Store", description: ""},
          careers: {title: "Careers", description: "Work with the team at Tzukuri"}
        }

        @html_klass = params[:page]
        page_sym = params[:page].parameterize.underscore.to_sym

        if !meta[page_sym].nil?
          @page_title = meta[page_sym][:title]
          @page_desc = meta[page_sym][:description]
        end

        # if the store should apply a $100 discount (only used on reservation)
        @code = params[:code]
        @discount = 0

        if !@code.nil?
          @discount = Tzukuri::DISCOUNTS[@code.to_sym] || 0
        end

        begin
            render action: params[:page]
        rescue ActionView::MissingTemplate
            raise ActionController::RoutingError.new('')
        end
    end
end
