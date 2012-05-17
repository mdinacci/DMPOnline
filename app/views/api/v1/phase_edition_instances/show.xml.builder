xml.instruct!
xml.dmponline do
  unless @error.blank?
    xml.error(@error)
  end

  xml.template_instance("instance_key" => @phase_edition_instance.id, "edition_key" => @phase_edition_instance.edition_id) do
    qs = @phase_edition_instance.report_questions
    number_questions(qs)
    unless params[:question_key].blank?
      apply_selection(qs, [params[:question_key].to_i])
    end
    dcc_q_numbering = dcc_numbering(@phase_edition_instance.edition)
    q_kinds = Question::TYPES.invert

    qs.each do |q|
      answers = @phase_edition_instance.question_answers(q.id)
      xml.template_clause do
        xml.question(strip_tags(q.question), "question_key" => q.id, "kind" => q_kinds[q.kind], "number" => q.number_display)

        answers.each do |a|
          if q.is_mapped?
            xml.dcc_clause do
              xml.question(strip_tags(a.dcc_question.question), "question_key" => a.dcc_question_id, "mapped_to" => a.question_id,
                                      "kind" => q_kinds[a.dcc_question.kind], "number" => "DCC #{dcc_q_numbering[a.dcc_question.id]}")
              xml.answer(a.answer.nil? ? '' : a.answer.force_encoding('UTF-8'), "answer_key" => a.id, "updated_at" => a.updated_at)
            end
          else
            xml.answer(a.answer.nil? ? '' : a.answer.force_encoding('UTF-8'), "answer_key" => a.id, "updated_at" => a.updated_at)
          end
        end
      end
    end
  end
end