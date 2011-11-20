require 'google_places'

class GoogleDetailsJob < Struct.new(:location_id, :reference)
  def perform
    puts "[ GoogleDetailsJob ] (#{location_id}) Starting..."
    loc = Location.find_by_id(location_id)

    begin
      details = GooglePlaces.place_details(reference)

      if details
        result = details['result']
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
      Delayed::Job.enqueue(GoogleDetailsJob.new(location_id, reference), 0, 1.hour.from_now)
    end
  end
end
