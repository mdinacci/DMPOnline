class Phase < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :template
  has_many :editions, :dependent => :destroy
  has_many :questions, :through => :editions, :dependent => :restrict

  attr_accessible :phase, :position
  validates :phase, :presence => true

  acts_as_list :scope => :template_id
  default_scope order(:position)
  
  after_create do |phase|
    edition = phase.editions.build
    edition.save!
  end
  
  attr_accessor :delete_phase
  before_save do |phase|
    if phase.delete_phase
      phase.destroy
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
  
  def not_in_use?
    if questions.present?
      errors.add :base, I18n.t('dmp.admin.phase_in_use')
    end
    
    errors.blank?
  end
  
end
