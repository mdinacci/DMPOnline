class Currency < ActiveRecord::Base
  has_paper_trail
  
  has_many :plans, :dependent => :restrict
  
  attr_accessible :name, :symbol, :iso_code
  validates_presence_of :name, :symbol, :iso_code

  def destroy
    if not_in_use?
      super
    else
      false
    end
  end
  
  protected
  
  def not_in_use?
    if plans.present?
      errors.add :base, I18n.t('dmp.admin.currency_in_use')
    end
    
    errors.blank?
  end

end
