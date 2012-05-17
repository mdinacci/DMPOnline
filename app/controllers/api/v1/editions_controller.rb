class Api::V1::EditionsController < Api::V1::BaseController
  helper :questions
  
  # GET api/v1/templates
  def index
   @editions = @editions.includes(:phase => {:template => :organisation})
  end

  # GET api/v1/templates/1
  def show
  end
  
  # GET api/v1/templates/1/users
  def users
    @users = @edition.used_by
  end

  # GET api/v1/templates/1/usersCERIF
  def usersCERIF
    @users = @edition.used_by
  end

end
