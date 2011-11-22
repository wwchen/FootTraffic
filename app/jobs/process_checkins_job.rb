require 'update_location_job'

class ProcessCheckinsJob < Struct.new(:buffer_size)
  def perform
    puts "[ ProcessCheckinsJob ] (#{buffer_size}) Starting..."

    batch = Checkin.where(:processed => nil).limit(buffer_size)
    batch.map! { |i| i.place_id }.uniq!

    batch.each do |location_id|
      puts "Creating new job for #{location_id}"
      Delayed::Job.enqueue(UpdateLocationJob.new(location_id))
    end
  end
end
