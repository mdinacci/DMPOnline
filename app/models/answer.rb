class Answer < ActiveRecord::Base
  belongs_to :phase_edition_instance
  belongs_to :question
  belongs_to :dcc_question, :class_name => "Question", :foreign_key => "dcc_question_id"
  
  attr_accessor :grid_row
  attr_accessible :answer, :hidden, :position, :question_id, :dcc_question_id, :grid_row
  attr_readonly :question_id, :dcc_question_id
  validate :not_locked
  before_validation :check_array_values
  after_validation :set_default_value
  before_create :get_initial_value
  before_save :set_answered_flag
  after_update :update_other_occurrences
  after_update :update_dependencies
    
  TOKENS = %w[project budget start_date end_date lead_org other_orgs]


  def all_live_occurrences
    if self.question.is_mapped?
      self.phase_edition_instance.template_instance.plan.current_answers.where(dcc_question_id: self.dcc_question_id, hidden: false).uniq
    else
      [self]
    end
  end
  
  def mapped_guide
    Mapping.where(question_id: self.question_id, dcc_question_id: self.dcc_question_id).first.try(:guide)
  end
  def question_guide
    if self.question.try(:has_answer?)
      self.question.try(:guide)
    end
  end

  def mapped_boilerplates
    Mapping
      .select("boilerplate_texts.content")
      .joins(:boilerplate_texts).where(question_id: self.question_id, dcc_question_id: self.dcc_question_id)
      .all
  end

  # For multi-part answers (split across table rows).  Passed index for a 1-based array.  Zero implies default value for new row
  def part(p)
    if p > 0
      self.break_up[p]
    else
      self.default_response
    end
  end

  def delete_part(p)
    if p > 0
      self.answer = self.break_up.delete_at(p).join("\x1E")
    end
  end

  def break_up
    self.answer.to_s.split("\x1e")
  end

  protected
  
  def not_locked
    if self.phase_edition_instance.template_instance.plan.locked
      return errors.add(:base, I18n.t('dmp.locked_error'))
    end 
    true
  end
  
  def set_default_value
    if self.answer.blank?
      self.answer = "#{self.question.is_column? ? "\x1e" : ''}#{self.default_response}"
    end
    if self.position.blank?
      self.position = self.dcc_question.try(:lft) || self.question.lft
    end
    true
  end
  
  def default_response
    dv = self.dcc_question.try(:default_value) || self.question.default_value
    unless dv.blank?
      plan = self.phase_edition_instance.template_instance.plan
      dv = dv.gsub(/\[[a-z_]+\]/) {|m| expand_token(m[1..-2], plan)}
    end
    dv.to_s
  end
  
  def set_answered_flag
    stripped = ActionController::Base.helpers.strip_tags(self.answer) || ''
    stripped.sub!(/\x1e/, '')
    self.answered = stripped.present?
    true
  end
  
  def expand_token(token, plan)
    case token.to_sym
    when :project, :lead_org, :other_orgs
      plan.send(token.to_sym)
    when :budget
      if plan.currency.nil?
        ''
      else 
        "#{ActionController::Base.helpers.number_to_currency plan.budget, unit: plan.currency.symbol} (#{plan.currency.iso_code})"
      end
    when :start_date, :end_date
      l plan.send(token.to_sym), format: 'long'
    else
      "[#{token}]"
    end
  end

  def update_other_occurrences
    unless self.dcc_question_id.blank?
      Answer.update_all({:answer => self.answer, :answered => self.answered}, {:phase_edition_instance_id => self.phase_edition_instance.template_instance.plan.current_phase_edition_instance_ids, :dcc_question_id => self.dcc_question_id})
    end
  end
  
  def get_initial_value
    if self.answer.blank?
      d = Answer.joins(:phase_edition_instance)
            .where(:answered => true, :dcc_question_id => self.dcc_question_id, :phase_edition_instances => {:template_instance_id => self.phase_edition_instance.template_instance_id})
            .order('updated_at DESC')
            .first
      if d.try(:answered)
        self.answer = d.answer
        self.answered = d.answered
      end
    end
  end
  
  def check_array_values
    if self.question.is_column?
      update_part
    else
      self.answer = serialize_options(self.answer)
    end
  end

  def serialize_options(a)
    if a.is_a? Array
      a = a.delete_if{ |x| x.blank? }.join('|')
    end
    a   
  end

  def update_part
    parts = self.answer_was.to_s.split("\x1e")
    parts[0] = ''
    if self.grid_row.to_i <= 0 
      self.grid_row = parts.length
    end
    parts[self.grid_row.to_i] = serialize_options(self.answer)
    self.answer = parts.join("\x1e")
  end
  
  def update_dependencies
    # Find answers to all questions in this plan which depend on this answer and set the not_used flag as appropriate.
    # NB: SQL is MYSQL specific
    aq = self.dcc_question || self.question
    condition = ActiveRecord::Base.send(:sanitize_sql_array, ["%s", self.answer.to_s])

    sql = ActiveRecord::Base.connection()
    sql.execute <<EOSQL
      UPDATE answers a LEFT OUTER JOIN 
              questions q ON a.question_id = q.id AND q.dependency_question_id = #{aq.id} LEFT OUTER JOIN 
              questions d ON d.id = a.dcc_question_id AND d.dependency_question_id = #{aq.id} 
      SET a.not_used = CASE WHEN d.dependency_value RLIKE '^(.*\\\\|)?#{condition}(\\\\|.*)?$' THEN 0 WHEN q.dependency_value RLIKE '^(.*\\\\|)?#{condition}(\\\\|.*)?$' THEN 0 ELSE 1 END
      WHERE a.phase_edition_instance_id IN (0#{self.phase_edition_instance.template_instance.plan.current_phase_edition_instance_ids.join(',')})
            AND (q.id IS NOT NULL OR d.id IS NOT NULL)
EOSQL

  end

end
