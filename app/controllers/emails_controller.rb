class EmailsController < ApplicationController
    EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    
    def create
        if params[:email][:email].empty? || !(params[:email][:email] =~ EMAIL_REGEX)
            render json: {success: false, reason: 'Email invalid, try again.'}
            return
        end
        
        email = Email.create(email: params[:email][:email], ip: request.ip)
        render json: {success: true}
    end

    def csv
        lines = ["email,ip,created_at"]
        Email.all.each do |email|
            lines << "#{email.email},#{email.ip},#{email.created_at}"
        end
        render text: lines.join("\n")
    end
end
