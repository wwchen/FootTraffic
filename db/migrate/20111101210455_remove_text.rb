class RemoveText < ActiveRecord::Migration
  def self.up
    remove_column :checkins, :text
  end

  def self.down
    add_column :checkins, :text
  end
end
