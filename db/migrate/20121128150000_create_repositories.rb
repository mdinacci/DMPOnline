class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.references :organisation
      t.string     :name
      t.string     :sword_collection_uri
      t.string     :encrypted_username
      t.string     :encrypted_password
      t.string     :administrator_name
      t.string     :administrator_email
      t.boolean    :allow_obo, default: false
      
      t.boolean    :create_metadata_with_new_plan, default: true
      t.string     :filetypes

      t.timestamps
    end
    
  end
end
