class Page < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :organisation
  validates :position, :menu, :organisation_id, :page_type, :presence => true

  attr_accessible :title, :body, :slug, :menu, :position, :target_url, :organisation_id, :locale, :page_type 
  attr_readonly :organisation_id
  attr_accessor :page_type
  after_validation :check_page_type

  scope :menu, ->(menu) { where(:menu => MENU.index(menu)).order(:position) }
  
  MENU = %w[none help navigation]

  def self.for_org(organisation)
    where(:locale => I18n.locale, :organisation_id => organisation)
  end

  protected
  
  def check_page_type
    self.target_url = '' if self.page_type = 'landing'
  end
  
end
