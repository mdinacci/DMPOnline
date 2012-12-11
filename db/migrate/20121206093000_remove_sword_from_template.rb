class RemoveSwordFromTemplate < ActiveRecord::Migration
  def up
    remove_column :phase_edition_instances, :sword_edit_uri
    remove_column :template_instances, :sword_col_uri
    remove_column :templates, :sword_sd_uri
  end
  
  def down
    add_column :phase_edition_instances, :sword_edit_uri, :string
    add_column :template_instances, :sword_col_uri, :string
    add_column :templates, :sword_sd_uri, :string
  end
end
