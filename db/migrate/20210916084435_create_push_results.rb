class CreatePushResults < ActiveRecord::Migration[6.1]
  def change
    create_table :push_results do |t|
      t.integer :push_message_id
      t.integer :recepient_token_ids, array: true, default: []
      t.json :status_tickets
      t.integer :status, default: 0
      t.text :error

      t.timestamps
    end
  end
end
