require 'google_places'

class GoogleDetailsJob < Struct.new(:location_id, :reference)
  def perform
    loc = Location.find_by_id(location_id)

    begin
      result = GooglePlaces.place_details(reference)

      # TODO: actually load this data into the Location model
      p result

    rescue GooglePlaces::RateLimitException
      # Requeue the job se we can try it later
      Delayed::Job.enqueue(GoogleDetailsJob.new(location_id, reference))
    end
  end
end
