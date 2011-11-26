class LocationsController < ApplicationController
  def index
    @search = Location.search do
      fulltext params[:q]
    end
    @locations = @search.results
    respond_to do |format|
      format.html
      format.json { render :json => @locations }
    end
  end
end
