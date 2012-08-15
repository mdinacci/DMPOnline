class AddShibbolethIdToUser < ActiveRecord::Migration

  def change
    add_column :users, :shibboleth_id, :string
    
    add_index :users, :shibboleth_id
  end
  
end
