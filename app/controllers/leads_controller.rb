class LeadsController < ApplicationController
    EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    def create
        if params[:lead][:email].empty? || !(params[:lead][:email] =~ EMAIL_REGEX)
            render json: {success: false, reason: "that email address doesn't look right, please try entering it again."}
            return
        end

        lead = Lead.create(email: params[:lead][:email], ip: request.ip)
        render json: {success: lead.valid?}
    end
end
