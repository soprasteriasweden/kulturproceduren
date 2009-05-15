class CreateQuestionaires < ActiveRecord::Migration
  def self.up
    create_table :questionaires do |t|
      t.integer :event_id
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :questionaires
  end
end
