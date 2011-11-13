require 'open-uri'

class Location < ActiveRecord::Base
  serialize :daily
  serialize :weekly
  serialize :annually
  serialize :bounding_box

  validates :twitter_id, :uniqueness => true
  validates :daily,    :length => { :is => 24  }
  validates :weekly,   :length => { :is => 7   }
  validates :annually, :length => { :is => 365 }

  # Class method for getting JSON from the Twitter API
  # for a location specified by a twitter_id
  def self.get_twitter_data(twitter_id)
    req = open("http://api.twitter.com/1/geo/id/#{twitter_id}.json")
    loc_data = ActiveSupport::JSON.decode(req.read)

    return loc_data
  end

  # Instance method for getting location data for an instance
  # of the Location model (which already has a twitter_id)
  def twitter_data
    return Location.get_twitter_data(self.twitter_id)
  end

  # We have an ID, so go ahead and populate the instance with data
  # that we grabbed from Twitter
  def populate_twitter
    data = self.twitter_data

    self.name         = data['full_name']
    self.bounding_box = data['bounding_box']
    self.place_type   = data['place_type']

    self.daily    = Array.new(24).fill(0)
    self.weekly   = Array.new(7).fill(0)
    self.annually = Array.new(365).fill(0)

    return data
  end

end
