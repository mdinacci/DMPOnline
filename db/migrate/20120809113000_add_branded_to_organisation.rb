class AddBrandedToOrganisation < ActiveRecord::Migration

  def change
    add_column :organisations, :branded, :boolean, null: false, default: false
  end
  
end
