class AddDeletedToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :deleted, :boolean, default: false
  end
end
