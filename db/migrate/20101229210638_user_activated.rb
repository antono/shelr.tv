class UserActivated < ActiveRecord::Migration
  def self.up
    add_column :users, :activated, :boolean
  end

  def self.down
    remove_column :users, :activated
  end
end
