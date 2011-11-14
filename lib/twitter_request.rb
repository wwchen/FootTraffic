require 'time'
require 'net/http'

class TwitterRequest
  def self.location(id, attempt=10)
    return nil unless attempt >= 0

    url = "http://api.twitter.com/1/geo/id/#{id}.json"
    resp = Net::HTTP.get_response(URI(url))

    code = resp.code.to_i
    if(code == 200)
      # All is well! Return the data.
      return ActiveSupport::JSON.decode(resp.body)
    elsif(code == 420)
      # We're being rate-limted.
      # Get the information from the headers regarding when we can
      # continue pounding their servers.
      reset = resp['X-RateLimit-Reset']
      if(reset)
        sleep(Time.at(reset) - Time.now)
      else
        sleep(30)
      end
      
      self.location(id, attempt-1)

    elsif(code >= 500)
      # Something is down, wait 30 seconds and try again
      sleep(30)
      return self.location(id, attempt-1)
    else
      return nil
    end
  end
end
