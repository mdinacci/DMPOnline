class Organisation < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :organisation_type
  belongs_to :dcc_edition, :class_name => "Edition", :foreign_key => "dcc_edition_id"
  has_many :documents
  has_many :pages
  has_many :roles
  has_many :templates
  has_many :users
  
  has_attached_file :logo, :styles => {home: '320x92>', template: '256x72>', thumb: '48x48>'}
  has_attached_file :banner, :styles => {home: '320x92>', template: '256x72>'}
  has_attached_file :media_logo, :styles => {docx: ['320x92#', :png], template: '256x72>'}
  has_attached_file :stylesheet
  
  validates_format_of :domain, :with => /\A[a-z\.]{6,}\Z/
  validates_presence_of :short_name, :full_name, :organisation_type
  validates_inclusion_of :branded, :in => [true, false]
  
  attr_accessible :full_name, :domain, :url, :organisation_type_id, :default_locale, :dcc_edition_id,
                  :short_name, :logo, :banner, :media_logo, :stylesheet, :branded, :wayfless_entity
  scope :dcc, where(:domain => 'dcc.ac.uk')
  
end
