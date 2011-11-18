class ProcessCheckinsJob < Struct.new(:buffer_size)
  def perform
    batch = Checkin.where(:processed => nil).limit(buffer_size)
    batch.map! { |i| i.place_id }.uniq!

    Location.process_checkins(batch)
  end
end
