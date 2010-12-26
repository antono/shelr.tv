class CreateRecords < ActiveRecord::Migration
  def self.up
    create_table :records do |t|
      t.string :title
      t.text :description
      t.text :typescript
      t.text :timing
      t.text :meta
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :records
  end
end
