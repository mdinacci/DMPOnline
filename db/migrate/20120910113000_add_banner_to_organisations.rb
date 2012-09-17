class AddBannerToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :banner_file_name, :string
    add_column :organisations, :banner_content_type, :string
    add_column :organisations, :banner_file_size, :string
    add_column :organisations, :banner_updated_at, :string
  end
end
