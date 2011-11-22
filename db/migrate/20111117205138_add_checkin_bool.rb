class AddCheckinBool < ActiveRecord::Migration
  def self.up
    add_column :checkins, :processed, :boolean
  end

  def self.down
    remove_column :checkins, :processed
  end
end
