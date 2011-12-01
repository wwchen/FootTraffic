namespace :db do
  desc "Load FourSquare checkin data from original data file. File is specified by path="
  task :load_checkins => :environment do
    path = ENV['path']
    if path
      puts "Reading in database file at #{path}"

      file = File.open(path, 'r')

      while(line = file.gets)
        data = line.split("\t")
        if(data.length == 7)
          matching = /I'm at (.*?) (\(|w\/|http)/.match(data[5])
          matching ||= /\(@ (([^w]|w[^\/])*)(w\/.*)?\)/.match(data[5])
          name = matching[1] if matching

          url_match = /(http:\/\/[^ ]*)$/.match(data[5])
          url = url_match[1] if url_match

          checkin = Checkin.create(
            :user_id    => data[0].strip,
            #:tweet_id   => data[1].strip,
            :latitude   => data[2].strip.to_f,
            :longitude  => data[3].strip.to_f,
            :post_date  => DateTime.parse(data[4]),
            :place_id   => data[6].strip,
            :place_name => name,
            :url        => url,
          )
          checkin.save
          p checkin.id
        end
      end
      
      file.close

    else
      puts "You did not specify a path to the checkin data!"
      puts "Use \"rake db:load_checkins path=/path/to/file\" in the future"
    end
  end
end
