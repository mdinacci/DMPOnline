class Mapping < ActiveRecord::Base
  belongs_to :question
  belongs_to :dcc_question, :class_name => "Question", :foreign_key => "dcc_question_id"
  has_one :guide, :as => :guidance, :dependent => :delete
  has_many :boilerplate_texts, :as => :boilerplate, :dependent => :delete_all

  accepts_nested_attributes_for :guide, :allow_destroy => true, :reject_if => :guide_empty
  accepts_nested_attributes_for :boilerplate_texts, :allow_destroy => true, :reject_if => :bp_empty
  attr_accessible :question_id, :dcc_question_id, :position, :guide_attributes, :boilerplate_texts_attributes

  acts_as_list :scope => :question_id
  default_scope order(:position)


  protected
  
  def guide_empty(attributes)
    Sanitize.clean(attributes['guidance']).blank?
  end
  
  def bp_empty(attributes)
    Sanitize.clean(attributes['content']).blank?
  end
  
end
