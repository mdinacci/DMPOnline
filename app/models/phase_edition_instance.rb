class PhaseEditionInstance < ActiveRecord::Base
  belongs_to :template_instance
  belongs_to :edition
  has_many :answers, :dependent => :delete_all
  has_many :questions, :through => :answers
  has_many :template_instance_rights, :through => :template_instance
  has_many :repository_action_queues, :dependent => :destroy

  accepts_nested_attributes_for :answers, :allow_destroy => true
  attr_accessible :answers_attributes, :edition_id

  attr_accessor :active_check


  scope :sorted, joins(:edition => :phase).order("phases.position")  
  scope :with_role, ->(role) { joins(:template_instance_rights).where('template_instance_rights.role_flags = ?', TemplateInstance::ROLES.index(role)) }
  scope :rights_matching, ->(email) { joins(:template_instance_rights).where("? LIKE template_instance_rights.email_mask", email) }

  def self.for_user(user)
    # Check all template instances for access rights for provided user
    user ||= User.new
    joins(:template_instance => :plan).includes(:template_instance_rights).where("plans.user_id = ? OR ? LIKE email_mask", user.id, user.email)
  end


  after_destroy do |pvi|
    pvi.active_check = true
  end

  after_create do |pvi|
    Question.for_edition(pvi.edition_id).each do |q|
      if q.is_mapped?
        q.mappings.each do |m|
          d = Answer.joins(:phase_edition_instance => :template_instance)
                .where(:answered => true, :dcc_question_id => m.dcc_question_id, :phase_edition_instances => {:template_instances => {:plan_id => pvi.template_instance.plan_id}})
                .order('updated_at DESC')
                .first
          pvi.answers.create!(question_id: q.id, dcc_question_id: m.dcc_question_id, position: m.position, answer: d.try(:answer))
        end
      else
        pvi.answers.create!(question_id: q.id) if q.has_answer?
      end
    end

    pvi.active_check = true
  end

  after_commit do |pvi|
    if pvi.active_check
      pvi.edition.active_check
    end
  end

  def question_answers(q_id)
    self.answers
      .where(:question_id => q_id)
      .where(:hidden => false)
      .order('answers.position')
      .all
  end
  
  def child_questions(q_id)
    self.questions
      .where(parent_id: q_id)
      .order('answers.position')
      .all
  end
  
  def child_answers(q_id)
    columns = child_questions(q_id).collect(&:id)
    self.answers
      .where(question_id: columns)
      .order('answers.position')
      .all
  end
  
  def child_answered(q_id)
    !self.questions
      .where(parent_id: q_id, 'answers.answered' => true)
      .all
      .empty?
  end
  
  def report_questions
    self.edition
      .questions
      .nested_set
      .all
  end 

  def include_question(q_id)
    result = false
    q = self.questions.where("questions.id" => q_id).first
    if q.nil?
      result = true
    else
      if q.dependency_question_id
        a = self.answers.where("answers.question_id = ? OR answers.dcc_question_id = ?", q_id, q_id).first
        if q.dependency_value.split('|').include? a.try(:answer)
          result = true
        end
      else
        result = true
      end
    end
    result
  end

  def locked
    self.template_instance.plan.locked
  end
  
  def rebuild_answers
    Question.for_edition(self.edition_id).each do |q|
      if q.is_mapped?
        q.mappings.each do |m|
          a = self.answers.find_or_create_by_question_id_and_dcc_question_id(:question_id => q.id, :dcc_question_id => m.dcc_question_id)
          d = Answer.joins(:phase_edition_instance => :template_instance) 
                .where("answers.dcc_question_id = ? AND ((template_instances.plan_id = ? AND template_instances.current_edition_id = phase_edition_instances.edition_id) OR phase_edition_instances.template_instance_id = ?)", m.dcc_question_id, self.template_instance.plan_id, self.template_instance_id)
                .order('updated_at DESC')
                .first
          a.update_attributes(:answer => d.try(:answer))
        end
      end
    end
  end
  
  def plan_owner
    self.template_instance.plan.user_id
  end
end
