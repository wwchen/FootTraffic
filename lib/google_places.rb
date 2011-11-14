# GooglePlaces
# A wrapper for interacting with the Google Places API

require 'net/http'

class GooglePlaces
  @api_key = 'AIzaSyD9PMj9-CRGuDygJa1ZJU5D9w3mp0Xa__E'

  # Search the Google Places API
  # A detailed breakdown of the parameters for this request is here:
  # http://code.google.com/apis/maps/documentation/places/#PlaceSearchRequests
  #
  # query has the following keys:
  # :latitude  => Self-explanatory
  # :longitude => Self-explanatory
  # :radius    => How far away to search
  # :keyword   => Any arbitrary search term
  # :name      => Search by location name
  # :types     => An array of location types (e.g. airport)
  def search(query)
    url = 'https://maps.googleapis.com/maps/api/place/search/json?'
    url += "#{url}key=#{@api_key}"
    url += "&location=#{query[:latitude]},#{query[:longitude]}"
    url += "&sensor=false"
    url += "&radius=#{query[:radius]}"
    url += "&keyword=#{query[:keyword]}"
    url += "&name=#{query[:name]}"
    url += "&types=#{query[:types].join('|')}"

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
      return ActiveSupport::JSON.decode(response.body)
    else
      return nil
    end
  end
end
