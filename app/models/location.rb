require 'net/http'
require 'twitter_request'
require 'geocoder'

class Location < ActiveRecord::Base
  acts_as_taggable

  serialize :daily
  serialize :weekly
  serialize :annually
  serialize :bounding_box
  serialize :types

  validates :twitter_id, :uniqueness => true
  validates :daily,    :length => { :is => 24  }
  validates :weekly,   :length => { :is => 7   }
  validates :annually, :length => { :is => 365 }

  def before_validation
    self.daily    ||= Array.new(24).fill(0)
    self.weekly   ||= Array.new(7).fill(0)
    self.annually ||= Array.new(365).fill(0)

    #import_twitter # Uncomment in case of emergency
  end

  # Configure search options for Solr
  searchable do
    text   :name,       :boost => 5.0
    text   :address,    :boost => 5.0
    text   :place_type, :boost => 4.0
    text   :types,      :boost => 3.0
    text   :tag_list,   :boost => 1.0
    #text   :website
    string :twitter_id
    string :phone
    float  :rating

    location :coordinates
  end

  def coordinates
    #Sunspot::Util::Coordinates.new(self.geom.y, self.geom.x)
    Sunspot::Util::Coordinates.new(self.latitude, self.longitude)
  end

  # Search for a location using Solr
  # parameters:
  # :keywords  => A list of keywords to search for
  # :lat, :lng => Where to search around
  # :precision => How far away should we look? (defaults to 6)
  # :time      => UTC time (optional)
  # :busy      => If true, we're looking for places with lots of traffic
  def self.location_search(params)
    params[:precision] ||= 6

    s = Sunspot.search Location do
      keywords params[:keywords]

      if(params[:lat] && params[:lng])
        with(:coordinates).near(params[:lat], params[:lng],
                                :precision => params[:precision],
                                :boost     => 3)
      end

      order_by :score, :desc
    end

    # If we get no results nearby, search without factoring in location
    if(params[:lat] && params[:lng] && s.results.empty?)
      return self.location_search(:keywords => params[:keywords])
    end

    # We need to take into account the location's rating when sorting the results.
    # My rudimentary solution is simply multiplying the Solr score by the rating.
    results = Array.new
    s.hits.each do |hit|
      if(hit.result.rating)
        score = hit.score * hit.result.rating
      else
        # TODO: should we give a weight to unrated locations??
        score = hit.score
      end

      # Here's where the traffic patterns come into play...
      # If we're searching for busy places, multiply the score by the traffic pattern at that time
      # If we're searching for less crowded places, multuply the score by 1 - the traffic pattern
      if(params[:time])
        # Get the time the user gave us and put it into terms we can use (UTC)
        dt = Time.parse(params[:time])
        hour = hit.result.daily[dt.utc.hour]
        day  = hit.result.weekly[dt.utc.wday]
        # We're going to leave out annual resutls for now
        #year = hit.result.annually[dt.utc.yday]

        # TODO: What weight should hourly patterns get versus weekly patterns?
        if(params[:busy])
          score = score * hour
        else
          # TODO: What if the pattern is 1? Should we discard it or pad it slightly?
          score = score * (1 - hour)
        end
      end

      score = score / (0.1*Geocoder::Calculations.distance_between([hit.result.latitude,hit.result.longitude],[params[:lat],params[:lng]]))

      results << [score, hit.result]
    end

    results.sort! { |x,y| y[0] <=> x[0] }
    #ap results.map { |i| "#{i[0]} => #{i[1].name}" }
    results.map! { |i| i[1] }

    #results.each do |r|
    #  puts "(#{Geocoder::Calculations.distance_between([params[:lat],params[:lng]],[r.latitude,r.longitude])}) #{r.name}"
    #end

    return results
  end

  def import_twitter
    # TODO: if we end up using this, make it handle the 
    # RateLimit exception thrown by TwitterReqeust
    data = TwitterRequest::location(self.twitter_id)
    if(data)
      self.name         = data['full_name']
      self.bounding_box = data['bounding_box']
      self.place_type   = data['place_type']

      return true
    else
      return false
    end
  end

  # Given an array of arrays, return an array with the average
  def self.matrix_average(matrices)
    matrix = matrices.reduce(Array.new(matrices.first.size).fill(0)) do |m,i|
      i.zip(m).map { |j| j.sum }
    end
    
    matrix = matrix.map { |i| i / matrix.sum.to_f }
    return matrix
  end

  # Update all patterns; requires a hash of the form:
  # { :daily => [], :weekly => [], :annually => [] }
  def update_patterns(patterns)
    self.update_daily(patterns[:daily])
    self.update_weekly(patterns[:weekly])
    self.update_annually(patterns[:annually])
  end

  # Average traffic pattern 'a' with the daily t-pat
  def update_daily(a)
    updated = Location.update_pattern(self.daily, a)
    self.daily = updated unless !updated
    self.save!
  end

  # Average traffic pattern 'a' with the weekly t-pat
  def update_weekly(a)
    updated = Location.update_pattern(self.weekly, a)
    self.weekly = updated unless !updated
    self.save!
  end

  # Average traffic pattern 'a' with the annual t-pat
  def update_annually(a)
    updated = Location.update_pattern(self.annually, a)
    self.annually = updated unless !updated
    self.save!
  end
  
  # Given two traffic patterns, averages them together
  def self.update_pattern(pattern, a)
    return nil unless pattern.size == a.size
    pattern.zip(a).map { |i| i.sum / 2.0 }
  end

end
