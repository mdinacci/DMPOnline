xml.instruct!
xml.dmponline do
  unless @error.blank?
    xml.error(@error)
  end
  xml.response(@answer.answer,
              response_key: @answer.id,
              locked: @lock,
              question_key: @answer.dcc_question_id.blank? ? @answer.question_id : @answer.dcc_question_id, 
              mapped_to: @answer.dcc_question_id.blank? ? nil : @answer.question_id,
              updated_at: @answer.updated_at)
end