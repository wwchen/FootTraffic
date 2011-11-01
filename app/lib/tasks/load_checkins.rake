namespace :db do
  desc "Load FourSquare checkin data from original data file. File is specified by path="
  task :load_checkins => :environment do
    path = ENV['path']
    if path
      puts "Reading in database file at #{path}"

      f = File.open(path, 'r')
    else
      puts "You did not specify a path to the checkin data!"
    end
  end
end
