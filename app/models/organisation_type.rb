class OrganisationType < ActiveRecord::Base
  has_paper_trail
  
  has_many :organisations, :order => "full_name"

  validates_presence_of :title
  attr_accessible :title, :description, :position
  default_scope order(:position)

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
