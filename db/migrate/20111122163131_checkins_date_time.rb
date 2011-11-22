class CheckinsDateTime < ActiveRecord::Migration
  def self.up
    change_column :checkins, :post_date, :datetime
  end

  def self.down
    change_column :checkins, :post_date, :date
  end
end
