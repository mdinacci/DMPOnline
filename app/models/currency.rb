class Currency < ActiveRecord::Base
  has_paper_trail
  
  has_many :plans
  
  attr_accessible :name, :symbol, :iso_code

end
