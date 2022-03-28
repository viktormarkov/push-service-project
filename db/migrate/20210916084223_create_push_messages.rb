class CreatePushMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :push_messages do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.column :city, :city, null: false
      t.integer :creator_id, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
