class Template < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :organisation
  has_many :phases, :order => 'position ASC'
  has_many :editions, :through => :phases
  has_many :questions, :through => :editions, :dependent => :restrict
  has_many :template_instances, :dependent => :restrict
  
  accepts_nested_attributes_for :phases, :allow_destroy => true, :reject_if => :phase_empty
  attr_accessible :organisation_id, :name, :url, :description, :constraint_limit, :constraint_text, :phases_attributes
  validates :name, :organisation, :presence => true
  validates_presence_of :phases

  def self.dcc_checklist
    where(:checklist => true)
    .first
  end
  
  def make_checklist(dcc_id)
    Template.where(checklist: true).update_all(checklist: false)
    if self.organisation_id == dcc_id
      self.checklist = true
      self.save!
    end
  end

  def destroy
    if not_in_use?
      super
    else
      false
    end
  end
  
  protected
  
  def phase_empty(attributes)
    Sanitize.clean(attributes['phase']).blank?
  end
  
  def not_in_use?
    if template_instances.present?
      errors.add :base, I18n.t('dmp.admin.template_in_use')
    elsif questions.present?
      errors.add :base, I18n.t('dmp.admin.template_built')
    end
    
    errors.blank?
  end
  
end
