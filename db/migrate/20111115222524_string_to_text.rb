class StringToText < ActiveRecord::Migration
  def self.up
    change_column :locations, :daily, :text
    change_column :locations, :weekly, :text
    change_column :locations, :annually, :text
  end

  def self.down
    change_column :locations, :daily, :string
    change_column :locations, :weekly, :string
    change_column :locations, :annually, :string
  end
end
