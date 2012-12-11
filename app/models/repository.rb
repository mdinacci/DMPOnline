class Repository < ActiveRecord::Base
  has_paper_trail

  belongs_to :organisation
  has_many :repository_action_queues
  has_many :repository_usernames
  has_many :plans
  
  attr_encrypted :username, key: :encryption_key, encode: true
  attr_encrypted :password, key: :encryption_key, encode: true
  attr_accessible :name, :organisation_id, :sword_collection_uri, :username, :password, :administrator_name, :administrator_email
  attr_accessible :create_metadata_with_new_plan, :filetypes, :allow_obo

  validates_presence_of :name, :organisation, :sword_collection_uri, :filetypes
  validates_inclusion_of :allow_obo, in: [true, false], allow_nil: false
  validates_uniqueness_of :name, scope: :organisation_id
  validates :administrator_email, :email => true
  validates :sword_collection_uri, :url => true
  
  before_validation :filetypes_from_array

  def self.for_org(organisation)
    where(:organisation_id => organisation)
  end
  
  def get_connection(on_behalf_of = nil)
    user = Sword2Ruby::User.new(self.username, self.password, on_behalf_of)
    connection = Sword2Ruby::Connection.new(user)
  end

  def filetype?(format)
    self.filetypes_list.include?(format.to_s)
  end
  
  def filetypes_list
    self.filetypes.to_s.split(' ')
  end
  
  protected
  
  def filetypes_from_array
    if self.filetypes.is_a?(Array)
      self.filetypes = self.filetypes.join(' ').strip
    end
    true
  end
  
  def encryption_key
    Rails.application.config.repository_key
  end
  
end
