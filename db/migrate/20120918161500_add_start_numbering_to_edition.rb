class AddStartNumberingToEdition < ActiveRecord::Migration
  def change
    add_column :editions, :start_numbering, :integer, default: 1
  end

end
