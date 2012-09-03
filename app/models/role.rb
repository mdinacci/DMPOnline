class Role < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :user
  belongs_to :organisation
  belongs_to :edition
  
  scope :dcc, -> { where(:organisation_id => Organisation.dcc.first.id) }
  scope :for_organisation, ->(org) { where(:organisation_id => org.id) }
  scope :for_user, ->(user) { where(:user_id => user.id) }
  scope :with_role, ->(role) { where(:role_flags => 2**User::ROLES.index(role.to_s)) }

  attr_accessible :user_email, :role_flags, :organisation_id, :edition_id
  attr_accessor :user_email
  attr_readonly :role_flags
  validates_presence_of :user, message: nil
  validates_uniqueness_of :role_flags, scope: [:user_id, :organisation_id]
  before_validation :set_user
  after_initialize :load_user
  

  def assigned=(role)
    self.role_flags = 2**User::ROLES.index(role.to_s)
  end
  
  def assigned
    User::ROLES.reject { |r| ((role_flags || 0) & 2**User::ROLES.index(r)).zero? }.map(&:to_sym)
  end
  
  
  protected
  
  def load_user
    if self.user_email.nil?
      self.user_email = self.user.try(:email)
    end
  end
  
  def set_user
    u = User.find_by_email(self.user_email)
    self.user_id = u.try(:id)
    if self.user_id.nil?
      self.errors.add(:user_email, I18n.t('dmp.validation.address_not_found'))
    end
  end
  
end
