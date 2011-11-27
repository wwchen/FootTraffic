class LocationsController < ApplicationController
  def index
    if params[:q]
      query = Hash.new
      query[:keywords]  = params[:q]
      # TODO: uncomment me when not debugging
      #query[:lat]       = params[:lat].to_f
      #query[:lng]       = params[:lng].to_f
      query[:lat]       = 37.776549
      query[:lng]       = -122.429752
      query[:precision] = 4

      @locations = Location.location_search(query).results
    end

    respond_to do |format|
      format.html
      format.json { render :json => @locations }
    end
  end
end
