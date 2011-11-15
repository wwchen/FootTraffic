require 'google_places'

# For a given location (specified by :location_id),
# grab the "reference" so we can get its details.

class GoogleSearchJob < Struct.new(:location_id)
  def perform
    loc = Location.find_by_id(location_id)

    query = {
      :latitude => loc.latitude,
      :longitude => loc.longitude,
      :radius => 500,
      :name => loc.name
    }

    begin
      result = GooglePlaces.search(query)

      reference = result['results'].first['reference']

      Delayed::Job.enqueue(GoogleDetailsJob.new(location_id, reference)

    rescue GooglePlaces::RateLimitException
      # Requeue the job so we can try it later
      Delayed::Job.enqueue(GoogleSearchJob.new(location_id))
    end
  end
end
