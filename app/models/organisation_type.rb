class OrganisationType < ActiveRecord::Base
  has_many :organisations, :order => "full_name"

  attr_accessible :title, :description, :position
  default_scope order(:position)

end
