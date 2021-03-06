require 'google_places'

class GoogleDetailsJob < Struct.new(:location_id, :reference, :key_num)
  def perform
    puts "[ GoogleDetailsJob ] (#{location_id},#{key_num}) Starting..."
    loc = Location.find_by_id(location_id)

    begin
      @key_num ||= 0
      details = GooglePlaces.place_details(reference, key_num)

      if details
        result = details['result']
        loc.name    = result['name']
        loc.address = result['formatted_address']
        loc.phone   = result['formatted_phone_number']
        loc.icon    = result['icon']
        loc.rating  = result['rating']
        loc.types   = result['types']
        loc.url     = result['url']
        loc.website = result['website']
        loc.save!
      end

    rescue GooglePlaces::RateLimitException
      # Requeue the job se we can try it later
      Delayed::Job.enqueue(GoogleDetailsJob.new(location_id, reference, key_num), 0, 1.hour.from_now)
    end
  end

  #def error(job, exception)
  #  logger.error(job)
  #  logger.error(exception)
  #end

  #def failure
  #  logger.fatal('[ GoogleDetailsJob ] Something terrible has happened...')
  #end
end
