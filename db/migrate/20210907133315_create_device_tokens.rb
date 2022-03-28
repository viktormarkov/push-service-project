class CreateDeviceTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :device_tokens do |t|
      t.text :value, null: false
      t.column :city, :city, null: false
      t.timestamps
    end

    add_index :device_tokens, :city
  end
end
