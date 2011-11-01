class Checkins < ActiveRecord::Migration
  def self.up
    create_table :checkins do |t|
      t.string :user_id
      t.string :tweet_id
      t.string :latitude
      t.string :longitude
      t.date   :created
      t.string :text
      t.string :place_id
      t.timestamps
    end
  end

  def self.down
    drop_table :checkins
  end
end
