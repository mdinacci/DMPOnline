class CreateRepositoryUsernames < ActiveRecord::Migration
  def change
    create_table :repository_usernames do |t|
      t.references  :repository
      t.references  :user
      t.string      :obo_username
      
      t.timestamps
    end
        
  end
end
