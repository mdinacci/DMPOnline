# encoding: utf-8
module PhaseEditionInstancesHelper
  include QuestionsHelper
  
  def export_questions(pei, selection = [], conditionals = false, exclude_unanswered = false)
    if pei.is_a?(Plan)
      start_numbering = 1 
    else
      start_numbering = pei.edition.start_numbering
    end
    
    qs = pei.report_questions
    apply_selection(qs, selection)
    number_questions(qs, start_numbering)
    export_output(qs, pei, conditionals, exclude_unanswered)
  end

  def export_output(qs, pei, conditionals = false, exclude_unanswered = false)
    if pei.is_a?(Plan)
      dcc_q_numbering = dcc_numbering(pei.template_instances.first.current_edition)
    else
      dcc_q_numbering = dcc_numbering(pei.edition)
    end
    
    mark_table = 0
    export_dmp = []
    export_section = {}
    export_section[:number] = ''
    export_section[:heading] = ''
    export_section[:template_clauses] = []
    export_section[:q_id] = 0
    first = true
    qs.each do |q|
      if (q.depth == 0 && q.is_heading?)
        unless first
          export_dmp << export_section
        end
        export_section = {}
        export_section[:number] = q.number_display
        export_section[:heading] = sanitize q.question.force_encoding('UTF-8')
        export_section[:template_clauses] = []
        export_section[:q_id] = q.id
      end
      export_question = {}
      export_question[:number] = q.number_display
      export_question[:depth] = q.depth
      export_question[:kind] = q.kind
      export_question[:is_heading] = q.is_heading?
      export_question[:is_mapped] = q.is_mapped?
      export_question[:is_grid] = q.is_grid?

      if conditionals
        skip_condition = false
      else
        skip_condition = !pei.include_question(q.id)
      end 
      
      if exclude_unanswered
        if q.has_answer? || q.is_mapped?
          skip_answered = true
        elsif q.is_grid?
          skip_answered = !pei.child_answered(q.id)
        else
          skip_answered = false
        end
      else
        skip_answered = false
      end

      if q.is_grid?
        export_question[:grid] = mark_table = q.id
        skip_grid = skip_condition || skip_answered
      elsif mark_table == q.parent_id
        export_question[:grid] = q.parent_id
      else
        export_question[:grid] = mark_table = 0
        skip_grid = false
      end
      export_question[:question] = sanitize q.question.force_encoding('UTF-8')
      export_question[:answers] = []
      
      if q.has_answer? || q.is_mapped?
        if pei.is_a?(PhaseEditionInstance)
          q_answers = pei.question_answers(q.id)
        else
          q_answers = []
          pei.phase_edition_instances.each do |p|
            q_answers |= p.question_answers(q.id)
          end
        end

        q_answers.each do |a|
          opts = {}
          if (conditionals || !a.not_used) && (!exclude_unanswered || a.answered)
            if a.dcc_question.nil?
              opts[:dmp_number] = ''
              opts[:dmp_clause] = t('dmp.no_dcc_equivalent')
              opts[:kind] = q.kind
              export_question[:answers] << export_answer(q, a, opts)
            else
              opts[:dmp_number] = "DCC #{dcc_q_numbering[a.dcc_question.id]}"
              opts[:dmp_clause] = sanitize a.dcc_question.question
              opts[:kind] = a.dcc_question.kind
              export_question[:answers] << export_answer(a.dcc_question, a, opts)
            end
            skip_answered = false
          end
        end
      end

      # Don't include the heading if it's just a repeat of the section
      unless export_section[:q_id] == q.id && q.is_heading?
        unless skip_condition || skip_answered || skip_grid
          export_section[:template_clauses] << export_question
        end
      end
      
      first = false
    end

    unless export_section.blank?
      export_dmp << export_section
    end
    
    export_dmp
  end


  def export_answer(q, a, answer)
    answer_list = []

    parts = a.break_up
    if parts.length > 1
      parts.shift
    end
    parts.each do |d|
      if q.is_boolean?
        case d.to_s
          when '0'
            answer_list << t('dmp.boolean_no')
          when '1'
            answer_list << t('dmp.boolean_yes')
          else
            answer_list << ''
        end
      elsif q.is_select? || q.is_radio?
        if d.present?
          opts = question_options(q.options).invert
          answer_list << (opts[d].try(:dup) || d).force_encoding('UTF-8')
        else
          answer_list << ''
        end
      elsif q.is_checkboxes?
        if d.present?
          opts = question_options(q.options).invert
          responses = d.split('|').collect {|x| (opts[x].try(:dup) || x).force_encoding('UTF-8') }
          answer_list << responses
        else
          answer_list << ''
        end
      else
        answer_list << d.force_encoding('UTF-8')
      end
    end

    if answer_list.count > 1 || q.is_column?
      answer[:response] = answer_list
    else
      answer[:response] = answer_list.first
    end

    answer
  end

  def apply_selection(qs, selection)
    qs.delete_if{ |q| !selection.include?(q.id) }
    qs.sort!{ |a,b| selection.index(a.id) <=> selection.index(b.id) }
    
    # Always start with a section header
    if qs.any?
      qs.first.parent_id = nil
    end
  end

  def branded_logo(action, options = {})
    if current_organisation.branded? && current_organisation.media_logo.file?
      case action
      when :url, :path
        path = current_organisation.media_logo.send(action)
        image_tag path, options
      when :asset
        current_organisation.media_logo.send(:path)
      end
    else
      case action
      when :url
        image_tag 'dmp_logo.png', options
      when :path
        wicked_pdf_image_tag 'dmp_logo.png', options
      when :asset
        Rails.application.assets.find_asset('dmp_logo.png').pathname.to_s
      end
    end
  end

  def grid_responses(qs, pei)
    grid = []
    max_col = 0
    formatted = export_output(qs, pei)
    formatted.each do |s|
      s[:template_clauses].each do |c|
        col = []
        c[:answers].each do |a|
          col = a[:response].is_a?(Array) ? a[:response] : [a[:response].to_s]
        end
        max_col = col.length > max_col ? col.length - 1 : max_col
        grid << col
      end
    end
    # Pad all columns to have same number of rows
    (0 .. grid.length - 1).each do |i|
      grid[i].fill('', grid[i].length .. max_col)
    end

    grid.transpose
  end

  def grid_new_row(q_id, r)
    params[:row] ||= {}
    params[:row][q_id.to_s] ||= r
  end

  def repository_option_list
    Repository.order(:name).all.inject({}) do |hash, r|
      hash.merge!("#{r.name} (#{r.organisation.full_name})" => r.id)
    end
  end

  def obo_allowed_list
    Repository
      .select("repositories.id, repository_usernames.obo_username")
      .joins("LEFT OUTER JOIN repository_usernames ON repository_usernames.repository_id = repositories.id AND repository_usernames.user_id = #{current_user.id}")
      .where(allow_obo: true)
      .all
      .inject({}) do |hash, r|
        hash.merge!(r.id.to_s => r.obo_username)
      end
  end
end
