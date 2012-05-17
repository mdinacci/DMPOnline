class Api::V1::BaseController < ApplicationController
  respond_to :xml
  
  prepend_before_filter :end_session
  before_filter :authenticate_user!
  append_before_filter :expire_token
  
  load_and_authorize_resource

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_error
  end
  rescue_from CanCan::AccessDenied, :with => :render_not_found
  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  rescue_from ActionController::RoutingError, :with => :render_not_found
  rescue_from ActionController::UnknownController, :with => :render_not_found
  rescue_from ActionController::UnknownAction, :with => :render_not_found


  private
  
  def end_session
    if current_user
      sign_out current_user
    end
  end
  
  def expire_token
    if current_user && (current_user.token_created_at.nil? || current_user.timedout?(current_user.token_created_at) || current_user.current_sign_in_ip != request.remote_ip)
      current_user.token_created_at = nil
      current_user.authentication_token = nil
      current_user.save
      sign_out current_user
      handle_unverified_request
      raise CanCan::AccessDenied.new('Token expired')
    end
  end

  def render_not_found(exception)
    @error = exception.message || 'Not found'
    render :template => 'api/v1/tokens/create', :status => :not_found, :layout => false
  end
  
  def render_error(exception)
    logger.warn exception
    ExceptionNotifier::Notifier.exception_notification(request.env, exception).deliver
    @error = 'API Exception'
    render :template => 'api/v1/tokens/create', :status => 500, :layout => false
  end
  
  def current_ability
    @current_ability ||= Api::V1::Ability.new(current_user)
  end

end