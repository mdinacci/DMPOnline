class AddNotUsedToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :not_used, :boolean, default: false, required: true
  end
end
