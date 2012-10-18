class OrganisationType < ActiveRecord::Base
  has_paper_trail
  
  has_many :organisations, :order => "full_name"

  validates_presence_of :title
  attr_accessible :title, :description, :position
  default_scope order(:position)

  def self.for_checklist
    where(checklist_owner: true)
    .first
  end
  
  def make_checklist_owner
    if Template.dcc_checklist.blank? || Template.dcc_checklist.organisation.organisation_type_id == self.id
      OrganisationType.where(checklist_owner: true).update_all(checklist_owner: false)
      self.checklist_owner = true
      self.save!
    else
      errors.add :base, I18n.t('dmp.admin.checklist_already_set')
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
    if organisations.present?
      errors.add :base, I18n.t('dmp.admin.org_type_has_orgs')
    end
    
    errors.blank?
  end

end
