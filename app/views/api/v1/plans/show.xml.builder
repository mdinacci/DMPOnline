xml.instruct!
xml.dmponline do
  unless @error.blank?
    xml.error(@error)
  end
  
  unless @plan.id.blank?
    xml.dmp(plan_id: @plan.id, url: plan_url(@plan)) do
      xml.project_name(plan_display(@plan, :project))
      xml.lead_org(plan_display(@plan, :lead_org))
      xml.other_orgs(plan_display(@plan, :other_orgs))
      xml.project_start(plan_display(@plan, :start_date))
      xml.project_end(plan_display(@plan, :end_date))
      xml.budget(plan_display(@plan, :budget))
      
      @plan.template_instances.includes(:phase_edition_instances).each do |ti| 
        ti.phase_edition_instances.each do |pei|
          xml.template_instance("instance_key" => pei.id, "edition_key" => pei.edition_id) do
            qs = pei.report_questions
            number_questions(qs, pei.edition.start_numbering)
            unless params[:question_key].blank?
              apply_selection(qs, [params[:question_key].to_i])
            end
            dcc_q_numbering = dcc_numbering(pei.edition)
            q_kinds = Question::TYPES.invert
        
            qs.each do |q|
              answers = pei.question_answers(q.id)
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
      end
    end
  end
end