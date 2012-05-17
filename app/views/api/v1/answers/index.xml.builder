xml.instruct!
xml.dmponline do
  unless @error.blank?
    xml.error(@error)
  end

  xml.question(question_key: params[:question_key].to_i) do
    @answers.each do |a|
      xml.answer(a.answer,
                 answer_key: a.id,
                 instance_key: a.phase_edition_instance_id,
                 edition_key: a.phase_edition_instance.edition_id,
                 user: a.phase_edition_instance.template_instance.plan.user.email)
    end
  end
end