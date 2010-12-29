class UserNickname < ActiveRecord::Migration
  def self.up
    add_column :users, :nickname, :string, limit: 255
  end

  def self.down
  end
end
