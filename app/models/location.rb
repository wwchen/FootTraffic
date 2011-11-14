require 'net/http'
require 'twitter_request'

class Location < ActiveRecord::Base
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
