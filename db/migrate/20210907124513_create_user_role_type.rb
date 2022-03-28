class CreateUserRoleType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE user_role AS ENUM ('admin', 'manager');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE user_role;
    SQL
  end
end
