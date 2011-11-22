class ChangeDefaultProcessed < ActiveRecord::Migration
  def self.up
    remove_column :checkins, :processed
    add_column :checkins, :processed, :boolean, :default=>false
  end

  def self.down
  end
end
