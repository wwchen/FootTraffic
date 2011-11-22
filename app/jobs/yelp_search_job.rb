require 'yelp_request'

class YelpSearchJob < Struct.new(:location_id)
  def perform
    puts "[ YelpSearchJob ] (#{location_id}) Starting..."

    loc = Location.find_by_id(location_id)

    # Normally I'd split the search and the details requests
    # into two separate jobs, but in this case we don't have to.
    # After all, we're mimicing the behavior of a real user.
    url = YelpRequest.search(location_id)
    if url
      data = YelpRequest.details(url)

      # Add the data to our Location model
      # The focus of Yelp data is adding extra metadata to
      # improve our results from Solr
      loc.tag_list << data[:cats]
      loc.tag_list << data[:ngrams]
      loc.save!
    end
  end

  #def error(job, exception)
  #  logger.error(job)
  #  logger.error(exception)
  #end

  #def failure
  #  logger.fatal('[ YelpSearchJob ] Something terrible has happened...')
  #end
end
