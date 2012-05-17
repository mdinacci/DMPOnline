class Api::V1::PhaseEditionInstancesController < Api::V1::BaseController
  load_and_authorize_resource :edition
  load_and_authorize_resource :through => :edition
  helper :questions

  # GET api/v1/templates/1/instances
  def index
    @phase_edition_instances = @edition.phase_edition_instances.includes(:template_instance => [:plan => :user]).where('users.id IS NOT NULL')
  end

  # GET api/v1/templates/1/instances/1
  def show
  end

end
