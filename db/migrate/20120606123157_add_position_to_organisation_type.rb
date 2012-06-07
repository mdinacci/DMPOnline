class AddPositionToOrganisationType < ActiveRecord::Migration
  def change
    add_column :organisation_types, :position, :integer, :default => 0
    
    add_index :organisation_types, :position
  end
end
