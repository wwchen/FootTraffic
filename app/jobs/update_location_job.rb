#require 'google_places'
require 'google_search_job'
require 'yelp_search_job'

class UpdateLocationJob < Struct.new(:place_id, :key_num)
  def perform
    puts "[ UpdateLocationJob ] (#{place_id}) Starting..."

    key_num ||= 0

    checkins = Checkin.where(:place_id => place_id, :processed => false)
    puts "Processing #{checkins.count} checkins..."

    daily    = []
    weekly   = []
    annually = []

    if checkins.count > 0
      checkins.each do |checkin|
        time = checkin.post_date
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
          l.name       = c.place_name
          l.twitter_id = place_id
          l.latitude   = c.latitude.to_f
          l.longitude  = c.longitude.to_f
          #l.geom       = Point.from_x_y(c.longitude.to_f, c.latitude.to_f)
          l.daily      = pats[:daily]
          l.weekly     = pats[:weekly]
          l.annually   = pats[:annually]
        end

        # TODO: Some kind of error checking would be nice...
        location.save!

        # Now kick off a few jobs to populate other fields
        query = {
          #:latitude => location.geom.y,
          #:longitude => location.geom.x,
          :latitude  => location.latitude,
          :longitude => location.longitude,
          :radius    => 1000,
          :name      => location.name
        }

        # Kick off jobs to populate the Location's metadata
        Delayed::Job.enqueue(GoogleSearchJob.new(location.id, key_num))
        Delayed::Job.enqueue(YelpSearchJob.new(location.id))

        return true
      end
    end
  end

  #def error(job, exception)
  #  logger.error(job)
  #  logger.error(exception)
  #end

  #def failure
  #  logger.fatal('[ UpdateLocationJob ] Something terrible has happened...')
  #end
end

