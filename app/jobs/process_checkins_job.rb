require 'update_location_job'

class ProcessCheckinsJob < Struct.new(:buffer_size, :key_num)
  def perform
    puts "[ ProcessCheckinsJob ] (#{buffer_size}, #{key_num}) Starting..."

    batch = Checkin.where(:processed => false).limit(buffer_size)
    batch.map! { |i| i.place_id }.uniq!

    batch.each do |location_id|
      puts "Creating new job for #{location_id}, #{key_num}"
      @key_num ||= 0

      Delayed::Job.enqueue(UpdateLocationJob.new(location_id, key_num))
    end
  end

  #def error(job, exception)
  #  logger.error(job)
  #  logger.error(exception)
  #end

  #def failure
  #  logger.fatal('[ ProcessCheckinsJob ] Something terrible has happened...')
  #end
end
