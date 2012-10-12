class PhaseEditionInstance < ActiveRecord::Base
  belongs_to :template_instance
  belongs_to :edition
  has_many :answers, :dependent => :delete_all
  has_many :questions, :through => :answers
  has_many :template_instance_rights, :through => :template_instance

  accepts_nested_attributes_for :answers, :allow_destroy => true
  attr_accessible :sword_edit_uri, :answers_attributes, :edition_id

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
          pvi.answers.create!(:question_id => q.id, :dcc_question_id => m.dcc_question_id, :answer => d.try(:answer))        
        end
      else
        pvi.answers.create!(:question_id => q.id) unless q.is_heading?
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
  
  def report_questions
    self.edition
      .questions
      .nested_set
      .all
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
