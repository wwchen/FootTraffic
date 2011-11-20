# GooglePlaces
# A wrapper for interacting with the Google Places API

require 'net/http'
require 'cgi'      # Never thought I'd do this in a Rails app...

class GooglePlaces
  @api_key = 'AIzaSyD9PMj9-CRGuDygJa1ZJU5D9w3mp0Xa__E'

  # Search the Google Places API
  # A detailed breakdown of the parameters for this request is here:
  # http://code.google.com/apis/maps/documentation/places/#PlaceSearchRequests
  #
  # query has the following keys (* fields are required):
  # :latitude*  => Self-explanatory
  # :longitude* => Self-explanatory
  # :radius*    => How far away to search
  # :keyword    => Any arbitrary search term
  # :name       => Search by location name
  # :types      => An array of location types (e.g. airport)
  def self.search(query)
    # We have to have the following fields:
    if(!query[:latitude] || !query[:longitude] || !query[:radius])
      return nil
    end

    # Any rules for escaping incoming strings can go here
    escape = lambda do |s|
      if s
        s.gsub!('&', 'and') # This little guy is quite a troublemaker...
        s = CGI.escape(s)   # THIS MUST BE THE LAST ONE, MK?
        s                   # Keep in mind the last value is what gets used...
      end
    end

    keyword = escape.call(query[:keyword])
    name    = escape.call(query[:name])
    types   = escape.call(query[:types])
    radius  = escape.call(query[:radius].to_s)

    # A quick note about URI escaping...
    # Why use CGI.escape instead of URI.escape?
    # CGI.escape does EVERYTHING, while URI.escape leaves in
    # characters like ampersands, which we want escaped.
    url = 'https://maps.googleapis.com/maps/api/place/search/json?'
    url += "key=#{@api_key}"
    url += "&location=#{query[:latitude]},#{query[:longitude]}"
    url += "&sensor=false"
    url += "&radius=#{radius}"
    url += "&keyword=#{keyword}" unless !keyword
    url += "&name=#{name}" unless !name
    url += "&types=#{types.map(&escape).join('|')}" unless !types

    p query
    
    return self.get(url)
  end

  # Google has kind of an annoying API...
  # In order to get the details on a place, you have to use a "reference"
  # which can only be obtained via a search and expires. Grrr.
  def self.place_details(reference)
    if(!reference) then return nil end
    url = 'https://maps.googleapis.com/maps/api/place/details/json?'
    url += "key=#{@api_key}&"
    url += "reference=#{reference}&"
    url += "sensor=false"

    return self.get(url)
  end

  # Actually handles the HTTP request and rate-limiting
  def self.get(url, attempt=10)
    return nil unless attempt >= 0

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)

    # There's some potential attacks we're opening ourselves up to
    # with this code; we aren't checking certs and for all we know
    # the person on the other end isn't who they say they are.
    # If we were to do this for real we'd fix this, but it isn't much
    # of a threat to warrant any attention for a class project.
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    
    code = response.code.to_i
    if(code == 200)
      json = ActiveSupport::JSON.decode(response.body)
      status = json['status']
      if(status == 'OK')
        return json
      elsif(status == 'OVER_QUERY_LIMIT')
        raise self.RateLimitException
      elsif(status == "ZERO_RESULTS")
        puts "No results found."
        return nil
      else
        # Zoinks! We need to retry the request...
        self.get(url, attempt-1)
      end
    else
      puts "Unknown HTTP code #{code}"
      return nil
    end
  end

  class RateLimitException < Exception
  end
end
