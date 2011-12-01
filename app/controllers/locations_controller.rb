class LocationsController < ApplicationController
  # The following parameters are accepted:
  # :q  => The search query
  # :lat => The user's latitude
  # :lng => The user's longitude
  # :time => The time to search on (defaults to the current time)
  # :busy => If set to anything, favors results with busy traffic patterns at :time
  def index
    if(params[:time])
      params[:time] = DateTime.parse(params[:time])
    else
      params[:time] = DateTime.now.utc.to_s
    end

    if params[:q]
      query = Hash.new
      query[:keywords]  = params[:q]
      # TODO: uncomment me when not debugging
      query[:lat]       = params[:lat].to_f
      query[:lng]       = params[:lng].to_f
      #query[:lat]       = 37.776549
      #query[:lng]       = -122.429752
      query[:precision] = 4
      query[:time]      = params[:time]
      query[:busy]      = params[:busy]

      @locations = Location.location_search(query)
    end

    respond_to do |format|
      format.html
      format.json { render :json => @locations }
    end
  end
end
