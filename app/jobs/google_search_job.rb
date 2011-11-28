require 'google_places'
require 'geocoder'

# For a given location (specified by :location_id),
# grab the "reference" so we can get its details.

class GoogleSearchJob < Struct.new(:location_id, :key_num)
  def perform
    puts "[ GoogleSearchJob ] (#{location_id},#{key_num}) Starting..."
    loc = Location.find_by_id(location_id)

    query = {
      #:latitude => loc.geom.y,
      #:longitude => loc.geom.x,
      :latitude  => loc.latitude,
      :longitude => loc.longitude,
      :radius    => 1000,
      :keyword   => loc.name
    }

    begin
      @key_num ||= 0
      result = GooglePlaces.search(query, key_num)

      if(result)
        results = result['results']
        results.sort_by! do |r|
          lat  = r['geometry']['location']['lat']
          long = r['geometry']['location']['lng']
          #Geocoder::Calculations.distance_between([loc.geom.y,loc.geom.x],[lat,long])
          Geocoder::Calculations.distance_between([loc.latitude,loc.longitude],[lat,long])
        end

        reference = result['results'].first['reference']
        Delayed::Job.enqueue(GoogleDetailsJob.new(location_id, reference, key_num))
      end

    rescue GooglePlaces::RateLimitException
      # Requeue the job so we can try it later
      Delayed::Job.enqueue(GoogleSearchJob.new(location_id, key_num), 0, 1.hour.from_now)
    end
  end

  #def error(job, exception)
  #  logger.error(job)
  #  logger.error(exception)
  #end

  #def failure
  #  logger.fatal('[ GoogleSearchJob ] Something terrible has happened...')
  #end
end
