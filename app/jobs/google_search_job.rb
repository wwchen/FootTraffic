require 'google_places'
require 'geocoder'

# For a given location (specified by :location_id),
# grab the "reference" so we can get its details.

class GoogleSearchJob < Struct.new(:location_id)
  def perform
    puts "[ GoogleSearchJob ] (#{location_id}) Starting..."
    loc = Location.find_by_id(location_id)

    query = {
      :latitude => loc.latitude,
      :longitude => loc.longitude,
      :radius => 1000,
      :keyword => loc.name
    }

    begin
      result = GooglePlaces.search(query)

      if(result)
        results = result['results']
        results.sort_by! do |r|
          lat  = r['geometry']['location']['lat']
          long = r['geometry']['location']['lng']
          Geocoder::Calculations.distance_between([loc.latitude,loc.longitude],[lat,long])
        end

        reference = result['results'].first['reference']
        Delayed::Job.enqueue(GoogleDetailsJob.new(location_id, reference))
      end

    rescue GooglePlaces::RateLimitException
      # Requeue the job so we can try it later
      Delayed::Job.enqueue(GoogleSearchJob.new(location_id), 0, 1.hour.from_now)
    end
  end
end
