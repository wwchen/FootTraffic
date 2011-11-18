require 'net/http'
require 'twitter_request'

class Location < ActiveRecord::Base
  acts_as_taggable

  serialize :daily
  serialize :weekly
  serialize :annually
  serialize :bounding_box

  validates :twitter_id, :uniqueness => true
  validates :daily,    :length => { :is => 24  }
  validates :weekly,   :length => { :is => 7   }
  validates :annually, :length => { :is => 365 }

  def before_validation
    self.daily    ||= Array.new(24).fill(0)
    self.weekly   ||= Array.new(7).fill(0)
    self.annually ||= Array.new(365).fill(0)

    import_twitter
  end

  def import_twitter
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

  # Given a batch of (unique) twitter location IDs, calculates the traffic patterns
  # for each one and kicks off the Location creation process.
  def self.process_checkins(loc_ids)
    # Hash with location ID as key and list of DateTimes as values
    loc_ids.each do |id|
      # While we're iterating over stuff, go ahead and mark all of these as "processed"
      checkins = Checkin.where(:place_id => id, :processed => nil)
      checkins.each { |x| x.processed = true; x.save! }

      daily    = []
      weekly   = []
      annually = []

      times = checkins.map { |i| i.created }
      times.each do |time|
        daily    << (0..23).to_a.map   { |i| if(time.hour == i) then 1 else 0 end }
        weekly   << (0..6).to_a.map    { |i| if(time.wday == i) then 1 else 0 end }
        annually << (0..365).to_a.map  { |i| if(time.yday == i) then 1 else 0 end }
      end
      
      # Hooray, now we have traffic patterns for this batch!
      daily_pat  = self.matrix_average(daily)
      weekly_pat = self.matrix_average(weekly)
      annual_pat = self.matrix_average(annually)
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
