class FixDefaultMappingSort < ActiveRecord::Migration

  def up
    execute <<-EOSQL
      UPDATE mappings m INNER JOIN questions dq ON m.dcc_question_id = dq.id 
      SET m.position = dq.lft 
    EOSQL
  end
  
end
