class AddColumnTalentTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :talent_type, :string
  end
end
