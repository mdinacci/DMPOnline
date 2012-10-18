class AddChecklistOwnerToOrganisationType < ActiveRecord::Migration
  def change
    add_column :organisation_types, :checklist_owner, :boolean, :default => false
  end
end
