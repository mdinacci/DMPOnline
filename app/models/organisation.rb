class Organisation < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :organisation_type
  belongs_to :dcc_edition, :class_name => "Edition", :foreign_key => "dcc_edition_id"
  has_many :documents, :dependent => :restrict
  has_many :pages, :dependent => :restrict
  has_many :roles, :dependent => :restrict
  has_many :templates, :dependent => :restrict
  has_many :users, :dependent => :restrict
  has_many :posts, :dependent => :restrict
  
  has_attached_file :logo, :styles => {home: '320x92>', template: '256x72>', thumb: '48x48>'}
  has_attached_file :banner, :styles => {home: '320x92>', template: '256x72>'}
  has_attached_file :media_logo, :styles => {docx: ['320x92#', :png], template: '256x72>'}
  has_attached_file :stylesheet
  
  validates_format_of :domain, :with => /\A([a-z\.]{2,}\.[a-z]{2,})?\Z/
  validates_presence_of :short_name, :full_name, :organisation_type
  validates_inclusion_of :branded, :in => [true, false]
  
  attr_accessible :full_name, :domain, :url, :organisation_type_id, :default_locale, :dcc_edition_id,
                  :short_name, :logo, :banner, :media_logo, :stylesheet, :branded, :wayfless_entity
  scope :dcc, where(:domain => 'dcc.ac.uk')

  def destroy
    if not_in_use?
      super
    else
      false
    end
  end
  
  protected
  
  def not_in_use?
    if documents.present?
      errors.add :base, I18n.t('dmp.admin.org_has_docs')
    end
    if pages.present?
      errors.add :base, I18n.t('dmp.admin.org_has_pages')
    end
    if roles.present?
      errors.add :base, I18n.t('dmp.admin.org_has_roles')
    end
    if templates.present?
      errors.add :base, I18n.t('dmp.admin.org_has_templates')
    end
    if users.present?
      errors.add :base, I18n.t('dmp.admin.org_has_users')
    end
    if posts.present?
      errors.add :base, I18n.t('dmp.admin.org_has_posts')
    end
    
    errors.blank?
  end

end
