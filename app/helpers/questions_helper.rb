module QuestionsHelper

  def number_part(number, style = '')
    neg = (number < 0) ? -1 : 1
    number *= neg
    
    output = case style.to_sym
    when :I
      number == 0 ? 'N' : number.to_s_roman.upcase
    when :i
      number == 0 ? 'n' : number.to_s_roman.downcase
    when :A
      case number
      when 0
        '_'
      when 1
        'A'
      else
        number -= 1
        c = []
        while number > 0
          d = number.divmod(26)
          c << (65 + d[1])
          number = d[0]
        end
        c.pack('c*')
      end
    when :a
      case number
      when 0
        '_'
      when 1
        'a'
      else
        number -= 1
        c = []
        while number > 0
          d = number.divmod(26)
          c << (97 + d[1])
          number = d[0]
        end
        c.pack('c*')
      end
    when :X
      nil
    else
      number
    end
    
    return (neg < 0) ? "-#{output}" : output
  end
  
  def number_questions(questions, start_numbering)
    previous = [0]
    level = 0
    numbering = [start_numbering - 1]
    display = []
    questions.each do |q|
      level = previous.index(q.parent_id.to_i)
      if level.nil?
        level = previous.size
        previous[level] = q.parent_id.to_i
      end
      previous = previous.first(level+1)
      numbering = numbering.first(level+1)
      
      numbering[level] ||= 0
      numbering[level] += 1
      display[level] = number_part(numbering[level], q.number_style)
      numbering[level] -= 1 if display[level].nil?
      number_display = ''
      level.times do |i|
        if display[i].blank?
          number_display = ''
        else
          number_display += "#{display[i]}."
        end
      end
      q.number_display = "#{number_display}#{display[level]}"
      q.depth = level
    end
    questions
  end

  def translated_styles
     Question::NUMBER_STYLES.keys.inject({}) do |hash, k|  
       hash.merge!(I18n.t("dmp.styles.#{k}") => Question::NUMBER_STYLES[k])
     end
  end

  def translated_types
     Question::TYPES.keys.inject({}) do |hash, k| 
       hash.merge!(I18n.t("dmp.types.#{k}") => Question::TYPES[k])
     end
  end
  
  def question_type_css(kind)
    Question::TYPES.invert[kind]
  end
  
  def mapped_kind_option
    l = translated_types.invert['m']
    {l => 'm'}
  end

  def dcc_checklist_taken_edition(q)
    Question
    .select('DISTINCT dcc_question_id, question')
    .joins(:mappings)
    .where('questions.edition_id' => q.edition_id)
    .where('questions.id <> ?', q.id.to_i)
    .select('questions.id AS id, mappings.dcc_question_id AS dcc_question_id')
    .inject({}) do |hash, m|
      hash.merge!(m.dcc_question_id => truncate(strip_tags(m.question), :length => 50))
    end
  end

  def dcc_checklist_questions(e)
    dcc = Edition.where(id: e.dcc_edition_id.to_i).first
    if dcc.blank?
      []
    else
      number_questions(dcc.sorted_questions, dcc.start_numbering)
    end
  end
  
  def dcc_checklist_pick(e)
    display_numbered_questions(dcc_checklist_questions(e))
  end
  
  def dcc_numbering(e)
    qs = dcc_checklist_questions(e)
    qs.inject({}) do |hash, q|
      hash.merge!(q.id => q.number_display) 
    end   
  end

  def question_type_title(k)
    types = Question::TYPES.invert
    types[k].humanize
  end

  def dcc_checklist_editions
    Edition.dcc_checklist_editions.inject({}) do |hash, v| 
      hash.merge!("#{v.short_name} #{v.phase.phase} [#{v.edition}]" => v.id) 
    end
  end
  
  def dependency_question_options(question)
    qs = Question.questions_in_edition(question)
    display_numbered_questions(number_questions(qs, question.edition.start_numbering), [question.id])
  end
  def dependency_dcc_question_options(question)
    q = Question.new(:edition_id => question.edition.dcc_edition_id.to_i)
    qs = Question.questions_in_edition(q)
    display_numbered_questions(number_questions(qs, question.edition.start_numbering), [question.id])
  end

  def display_numbered_questions(c, omit = [])
    c.inject({}) do |hash, q|
      if omit.include?(q.id) || q.is_heading? || q.is_mapped?
        hash
      else
        hash.merge!("#{q.number_display} #{abbreviated_question(q)}" => q.id)
      end
    end
  end

  def abbreviated_question(q)
    truncate(strip_tags(q.question), :length => 200)
  end

  def question_options(q_options)
    opts = {}
    if q_options.present?
      q_options.split(/[\r\n]/).each do |opt|
        next if opt.blank?
        name, val = opt.split('|')
        val ||= name
        opts.merge!(name => val) unless name.blank?
      end
    end
    
    opts
  end
  
end
