require 'inherited_resources'

class ActiveAdmin::ResourceController < ActiveAdmin::BaseController

  protected

  def current_ability
    @current_ability ||= AdminAbility.new(current_user)
  end
  
  def admin_authorize!
    current_ability.authorize!(action_name, controller_name)
  end

end 
