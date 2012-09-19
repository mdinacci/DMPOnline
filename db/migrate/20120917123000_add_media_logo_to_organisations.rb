class AddMediaLogoToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :media_logo_file_name, :string
    add_column :organisations, :media_logo_content_type, :string
    add_column :organisations, :media_logo_file_size, :integer
    add_column :organisations, :media_logo_updated_at, :datetime
  end

end
