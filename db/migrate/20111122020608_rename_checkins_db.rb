class RenameCheckinsDb < ActiveRecord::Migration
  def self.up
    rename_table :checkins, :oldcheckins
  end

  def self.down
    rename_table :oldcheckins, :checkins
  end
end
