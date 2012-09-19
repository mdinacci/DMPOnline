xml.instruct!
xml.dmponline do
  unless @error.blank?
    xml.error(@error)
  end

  xml.template_edition("edition_key" => @edition.id) do 
    dcc_numbers = dcc_numbering(@edition)
    qs = number_questions(@edition.sorted_questions, @edition.start_numbering)
    q_kinds = Question::TYPES.invert

    qs.each do |q|
      xml.question(strip_tags(q.question), "question_key" => q.id, "kind" => q_kinds[q.kind], "number" => q.number_display)

      q.mappings.includes(:dcc_question).each do |m|
        unless m.dcc_question.nil?
          xml.question(strip_tags(m.dcc_question.question), "question_key" => m.dcc_question.id, "mapped_to" => m.question_id,
                                  "kind" => q_kinds[m.dcc_question.kind], "number" => "DCC #{dcc_numbers[m.dcc_question.id]}")
        end
      end
    end
  end
end