class CreateCheckins < ActiveRecord::Migration
  def self.up
    create_table :checkins do |t|
      t.string  :user_id
      t.string  :place_id
      t.string  :place_name
      t.date    :post_date
      t.string  :city_state
      t.float   :latitude
      t.float   :longitude
    end
  end

  def self.down
    drop_table :checkins
  end
end
