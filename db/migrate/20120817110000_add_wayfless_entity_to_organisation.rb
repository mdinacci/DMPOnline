class AddWayflessEntityToOrganisation < ActiveRecord::Migration

  def change
    add_column :organisations, :wayfless_entity, :string
  end
  
end
