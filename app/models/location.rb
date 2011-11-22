require 'net/http'
require 'twitter_request'

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
    text   :types,      :boost => 4.0
    text   :tag_list,   :boost => 3.0
    text   :website
    string :twitter_id
    string :phone
    float  :rating

    location :coordinates
  end

  def coordinates
    #Sunspot::Util::Coordinates.new(self.geom.y, self.geom.x)
    Sunspot::Util::Coordinates.new(self.latitude, self.longitude)
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
