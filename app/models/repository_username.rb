class RepositoryUsername < ActiveRecord::Base
  belongs_to :user
  belongs_to :repository

  validates :user_id, :repository_id, :presence => true
  
  def self.for_repository(repository)
    where(:repository_id => repository.id)
    .order('id desc')
    .first
    .try(:obo_username)
    .to_s
  end
  
end
