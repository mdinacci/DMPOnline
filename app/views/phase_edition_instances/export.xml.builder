xml.instruct!
xml.dmp do
  xml.project_name(plan_display(@plan, :project))
  xml.format do
    xml.header(@doc[:page_header_text])
    xml.footer(@doc[:page_footer_text])
    xml.font_face(@doc[:font_style])
    xml.font_size(@doc[:font_size])
    xml.signatures(@doc[:page_signatures_count])
    xml.orientation(@doc[:orientation])
  end
  if @doc[:project_status]
    xml.stage(t('dmp.project_stage', phase: @phase_edition_instance.edition.phase.phase))
  end
  if @doc[:template_org]
    xml.template_org("#{@phase_edition_instance.template_instance.template.organisation.organisation_type.title}: #{@phase_edition_instance.template_instance.template.organisation.full_name}")
  end
  if @doc[:partners]
    xml.lead_org(plan_display(@plan, :lead_org))
    xml.other_orgs(plan_display(@plan, :other_orgs))
  end
  if @doc[:project_dates]
    unless @plan.start_date.nil? 
      xml.project_start(plan_display(@plan, :start_date))
      unless @plan.end_date.nil?
        xml.project_end(plan_display(@plan, :end_date))
      end
    end
  end
  if @doc[:budget]
    xml.budget(plan_display(@plan, :budget))
  end
  
  qs = export_questions(@pei, @doc[:selection], @doc[:include_conditional], @doc[:exclude_unanswered])
  qs.each do |s|
    xml.section("number" => s[:number]) do
      xml.heading(clean_html(s[:heading]))
      s[:template_clauses] ||= []
      s[:template_clauses].each do |q|
        if q[:grid] == 0 || q[:is_grid]
          xml.template_clause do
            xml.question(clean_html(q[:question]), "number" => q[:number], "is_grid" => q[:is_grid], "is_mapped" => q[:is_mapped])
            if q[:is_grid]
              grid = number_questions(@pei.child_questions(q[:grid]), 1)
              grid.each do |col|
                xml.question(clean_html(col.question), "number" => col.number_display, "is_grid" => false)
              end
              responses = grid_responses(grid, @pei)
              responses.each do |row|
                xml.row do
                  row.each do |response|
                    xml.column do
                      response_xml_format(xml, response)
                    end
                  end
                end
              end
            else
              q[:answers].each do |a|
                xml.dcc_clause do
                  dcc_number = @doc[:dcc_question_numbers] ? a[:dmp_number].slice(4..-1) : ''
                  dcc_clause = @doc[:include_dcc_questions] ? clean_html(a[:dmp_clause]) : ''
                  xml.question(dcc_clause, "number" => dcc_number)
                  response_xml_format(xml, a[:response])
                end
              end
            end
          end
        end
      end
    end
  end
end
