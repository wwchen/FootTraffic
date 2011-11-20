require 'google_places'

class UpdateLocationJob < Struct.new(:place_id)
  def perform
    puts "[ UpdateLocationJob ] (#{place_id}) Starting..."

    checkins = Checkin.where(:place_id => place_id, :processed => nil)
    puts "Processing #{checkins.count} checkins..."

    daily    = []
    weekly   = []
    annually = []

    checkins.each do |checkin|
      time = checkin.created
      daily    << (0..23).to_a.map   { |i| if(time.hour == i) then 1 else 0 end }
      weekly   << (0..6).to_a.map    { |i| if(time.wday == i) then 1 else 0 end }
      annually << (0..364).to_a.map  { |i| if(time.yday == i) then 1 else 0 end }

      checkin.processed = true
      checkin.save!
    end

    pats = {
      :daily    => Location.matrix_average(daily),
      :weekly   => Location.matrix_average(weekly),
      :annually => Location.matrix_average(annually)
    }

    location = Location.find_by_twitter_id(place_id)

    if location
      # If the location already exists, update the patterns and leave it alone
      location.update_patterns(pats)
    else
      # Otherwise, we need to create it and kick off jobs to populate it
      c = checkins.first
      location = Location.new do |l|
        l.twitter_id = place_id
        l.latitude   = c.latitude.to_f
        l.longitude  = c.longitude.to_f
        l.daily      = pats[:daily]
        l.weekly     = pats[:weekly]
        l.annually   = pats[:annually]
      end

      # TODO: Some kind of error checking would be nice...
      location.save!

      # Now kick off a few jobs to populate other fields
      query = {
        :latitude => location.latitude,
        :longitude => location.longitude,
        :radius => 1000,
        :name => location.name
      }

      #puts "Performing Google search..."
      #search = GooglePlaces.search(query)
      #p search
      #puts ""
      #reference = search['results'].first['reference']
      #puts "Getting additional place details from Google... [ #{search['reference']} ]"
      #details = GooglePlaces.place_details(reference)
      #p details

      #Delayed::Job.enqueue(GoogleSearchJob.new(location.id))
    end
  end
end

