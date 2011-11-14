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

    # A quick note about URI escaping...
    # Why use CGI.escape instead of URI.escape?
    # CGI.escape does EVERYTHING, while URI.escape leaves in
    # characters like ampersands, which we want escaped.
    url = 'https://maps.googleapis.com/maps/api/place/search/json?'
    url += "#{url}key=#{@api_key}"
    url += "&location=#{query[:latitude]},#{query[:longitude]}"
    url += "&sensor=false"
    url += "&radius=#{CGI.escape(query[:radius].to_s)}"
    url += "&keyword=#{CGI.escape(query[:keyword])}" unless !query[:keyword]
    url += "&name=#{CGI.escape(query[:name])}" unless !query[:name]
    url += "&types=#{query[:types].map {|i| CGI.escape(i)}.join('|')}" unless !query[:types]
    
    return self.get(url)
  end

  def place_details(query)
    url = 'https://maps.googleapis.com/maps/api/place/details/json?'
    
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
      if(status != 'OK')
        return json
      elsif(status == 'OVER_QUERY_LIMIT')
        # TODO: Figure out something useful to do here...
        sleep(1000)
      else
        # Zoinks! We need to retry the request...
        self.get(url, attempt-1)
      end
    else
      return nil
    end
  end
end
