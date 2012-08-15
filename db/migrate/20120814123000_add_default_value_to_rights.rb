class AddDefaultValueToRights < ActiveRecord::Migration

  def up 
    change_column :template_instance_rights, :role_flags, :integer, :default => 2
  end

  def down 
    change_column :template_instance_rights, :role_flags, :integer, :default => nil 
  end 

end
