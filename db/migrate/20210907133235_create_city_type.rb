class CreateCityType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE city AS ENUM ('london', 'liverpool');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE city;
    SQL
  end
end
