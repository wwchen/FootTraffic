class UpdateCheckins < ActiveRecord::Migration
  def self.up
    add_column :checkins, :url,   :string
    add_column :checkins, :city,  :string
    add_column :checkins, :state, :string
    remove_column :checkins, :city_state
  end

  def self.down
    remove_column :checkins, :url
    remove_column :checkins, :city
    remove_column :checkins, :state
    add_column :checkins, :city_state, :string
  end
end

