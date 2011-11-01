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
          checkin = Checkin.create(
            :user_id   => data[0].strip,
            :tweet_id  => data[1].strip,
            :latitude  => data[2].strip,
            :longitude => data[3].strip,
            :created   => DateTime.parse(data[4]),
            :text      => data[5].strip,
            :place_id  => data[6].strip
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
