class RemoveJobs < ActiveRecord::Migration
  def self.up
    drop_table :delayed_jobs
  end

  def self.down
  end
end
