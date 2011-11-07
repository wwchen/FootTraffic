class MakeDatesDateTimes < ActiveRecord::Migration
  def self.up
    remove_column :checkins, :created
    add_column :checkins, :created, :datetime
  end

  def self.down
    remove_column :checkins, :created
    add_column :checkins, :created, :date
  end
end
