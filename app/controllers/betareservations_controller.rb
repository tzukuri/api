require 'csv'

class BetareservationsController < ApplicationController
  http_basic_authenticate_with name: "a@tzukuri.com", password: "ksV-Pxq-646-feS", except: :create

  def create
    @betareservation = Betareservation.create(
        name: params[:name],
        email: params[:email],
        address1: params[:address1],
        address2: params[:address2],
        state: params[:state],
        postcode: params[:postcode],
        country: params[:country],
        frame: params[:frame],
        colour: params[:colour],
        size: params[:size],
        model: params[:model]
    )

    if (@betareservation.valid?)
      render json: {success: true, betareservation: @betareservation}
    else
      render json: {success:false, errors:@betareservation.errors}
    end

  end

  def csv
    csv_string = CSV.generate do |csv|
      csv << Betareservation.attribute_names
      Betareservation.all.each do |betareservation|
        csv << betareservation.attributes.values
      end
    end

    render body: csv_string
  end
end
