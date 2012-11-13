class Question < ActiveRecord::Base
  has_paper_trail
  
  include TheSortableTree::Scopes
  
  acts_as_nested_set
  before_move :table_checks

  belongs_to :edition
#  has_many :dependents, :class_name => "Question"
  belongs_to :dependency, :class_name => "Question", :foreign_key => "dependency_question_id"
  has_many :mappings, :order => 'position ASC', :dependent => :destroy
  has_many :answers, :dependent => :restrict
  has_many :dcc_questions, :class_name => "Question", :through => :mappings, :foreign_key => "dcc_question_id"
  has_one :guide, :as => :guidance, :dependent => :delete
  has_many :boilerplate_texts, :as => :boilerplate, :dependent => :delete_all
  accepts_nested_attributes_for :guide, :allow_destroy => true
  accepts_nested_attributes_for :boilerplate_texts, :allow_destroy => true
  accepts_nested_attributes_for :mappings, :allow_destroy => true 
  attr_accessible :edition_id, :kind, :number_style, :question, :dependency_question_id, :dependency_value,
                  :guide_attributes, :boilerplate_texts_attributes, :mappings_attributes, 
                  :select_dcc_questions, :default_value, :options

  # Question types available:
  # boolean: a special choice type of Yes/No
  # text: a text area
  # mapped: mapped to DCC checklist answers.  Should not be used in DCC checklist.
  # heading: has no associated answer
  # uri: text input type for single line
  # select: dropdown menu of options (single option select)
  # multiselect: checkbox list of options (can select more than one option)
  # radio: radio button list of options (only one can be selected)
  # grid: has no associated answer, nested questions rendered as columns in a table layout
  TYPES = { 'mapped' => 'm',
            'text' => 't',
            'boolean' => 'b',
            'heading' => 'h',
            'uri' => 'u',
            'select' => 's',
            'multiselect' => 'l',
            'radio' => 'r',
            'grid' => 'g' }

  # Number style
  NUMBER_STYLES = { 'digits' => 'n',
                    'none' => 'X',
                    'caps' => 'A',
                    'lower' => 'a',
                    'upper_roman' => 'I',
                    'lower_roman' => 'i' }

  attr_accessor :number_display
  attr_accessor :depth
  attr_accessor :select_dcc_questions
  attr_accessor :check_parent
  after_validation :remove_blank_entries
  after_save :update_mappings
  validates_presence_of :edition
  validates_associated :edition
  validates_inclusion_of :kind, in: TYPES.values
  validates_inclusion_of :number_style, in: NUMBER_STYLES.values

  def self.questions_in_edition(q)
    where(:edition_id => q.edition_id)
    .nested_set
    .all
  end

  def is_heading?
    self.kind == 'h'
  end
  
  def is_text?
    self.kind == 't'
  end
  
  def is_mapped?
    self.kind == 'm'
  end
  
  def is_boolean?
    self.kind == 'b'
  end
  
  def is_select?
    self.kind == 's'
  end
  
  def is_radio?
    self.kind == 'r'
  end
  
  def is_checkboxes?
    self.kind == 'l'
  end
  
  def is_grid?
    self.kind == 'g'
  end
  
  def has_answer?
    !(self.is_heading? || self.is_grid? || self.is_mapped?)
  end
  
  def is_column?
    self.parent.try(:is_grid?)
  end
  
  def form_source
    case self.kind
    when 'b'
      "input:checked"
    when 't'
      "textarea"
    when 'u'
      "input"
    when 'l'
      "input:checked"
    when 'r'
      "input:checked"
    when 's'
      "select"
    else
      ''
    end
  end
  
  def is_dcc_checklist?
    self.edition.phase.template.checklist
  end
  
  def self.for_edition(eid)
    includes(:mappings)
    .where(:edition_id => eid)
    .all
  end

  def destroy
    if not_in_use?
      super
    else
      false
    end
  end
  
  private
  
  def remove_blank_entries
    unless self.guide.nil?
      if self.guide.guidance.blank?
        self.guide.destroy
      end
    end
    self.boilerplate_texts.each do |bp| 
      if bp.content.blank?
        bp.destroy
      end
    end
  end

  def organisation_id
    self.edition.phase.template.organisation_id
  end

  # after_save callback to handle mappings
  def update_mappings
    if !self.select_dcc_questions.nil? && self.select_dcc_questions.is_a?(Array)
      self.mappings.each do |m|
        m.destroy unless select_dcc_questions.include?(m.dcc_question_id.to_s)
        self.select_dcc_questions.delete(m.dcc_question_id.to_s)
      end

      self.select_dcc_questions.each do |q|
        self.mappings.create(:dcc_question_id => q) unless q.blank?
      end
            
      reload
      self.select_dcc_questions = nil
    end
  end

  def not_in_use?
    if answers.present?
      errors.add :base, I18n.t('dmp.admin.question_in_use')
    elsif descendants.present?
      errors.add :base, I18n.t('dmp.admin.question_nested')
    end
    
    errors.blank?
  end
  
  def table_checks
    unless self.check_parent.to_i.zero?
      parent = Question.find(self.check_parent)
      if parent.is_grid? 
        unless self.has_answer?
          errors.add :base, I18n.t('dmp.admin.bad_table_column')
        end
        unless self.leaf?
          errors.add :base, I18n.t('dmp.admin.bad_table_nesting')
        end
      end
      parent.ancestors.each do |a|
        if a.is_grid?
          errors.add :base, I18n.t('dmp.admin.bad_table_nesting')
        end
      end
    end
    
    errors.blank?
  end

end
