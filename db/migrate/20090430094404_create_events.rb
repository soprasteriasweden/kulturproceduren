class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :from_age
      t.integer :to_age
      t.text :description
      t.integer :ticket_state
      t.date  :show_date
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
