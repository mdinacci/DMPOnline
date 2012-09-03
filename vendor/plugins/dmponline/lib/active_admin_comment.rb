class ActiveAdmin::Comment < ActiveRecord::Base
  attr_accessible :resource_type, :resource_id, :body
end
