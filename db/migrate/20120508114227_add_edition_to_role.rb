class AddEditionToRole < ActiveRecord::Migration
  def change
    add_column :roles, :edition_id, :integer
    
    add_index :roles, :edition_id
  end
end
