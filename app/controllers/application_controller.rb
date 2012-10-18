class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_organisation, :dcc_organisation, :supported_locales,
                :using_shibboleth?, :shibboleth_enabled?, :shibboleth_user?

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_error
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError, :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found
    rescue_from ActionController::UnknownAction, :with => :render_not_found
  end
  rescue_from CanCan::AccessDenied do |exception|
    if current_user.try(:is_admin?) && controller_path.split('/').first == 'admin'
      redirect_to admin_dashboard_path, :alert => exception.message and return
    else
      render_access_denied
    end
  end
  
  before_filter :set_locale
  
  def default_url_options(opts={})
    if I18n.locale != I18n.default_locale
      opts[:locale] = I18n.locale.to_s
    end

    opts
  end
  

  def current_organisation
    @current_organisation ||= derive_organisation
  end
    
  def dcc_organisation
    @dcc_organisation ||= derive_checklist_organisation 
  end
    
  def supported_locales
    Rails.application.config.supported_locales || ['en']
  end
 
  def using_shibboleth?
    status = false
    if Rails.application.config.shibboleth_enabled
      if current_user.try(:shibboleth_id).present?
        status = true
      elsif !session[:shibboleth_data].blank?
        status = true 
      end
    end
    
    status
  end

  def shibboleth_enabled?
    Rails.application.config.shibboleth_enabled
  end

  def shibboleth_user?
    Rails.application.config.shibboleth_enabled && current_user.try(:shibboleth_id).present?
  end

  private
  
  def render_not_found(exception)
    render :template => "errors/404", :status => 404, :layout => "application" and return
  end
  
  def render_error(exception)
    logger.warn exception
    ExceptionNotifier::Notifier.exception_notification(request.env, exception).deliver
    render :template => "errors/500", :status => 500, :layout => "application" and return
  end
  
  def render_access_denied
    redirect_to :back, :alert => I18n.t('dmp.auth.no_access') and return
  rescue ActionController::RedirectBackError 
    redirect_to frontpage_path, :alert => I18n.t('dmp.auth.no_access') and return
  end
  
  def current_ability
    Ability.new(current_user, current_organisation, dcc_organisation)
  end

  def set_locale
    param_locale = params[:locale] || ''
    org = current_organisation || Organisation.new
    I18n.locale = ([param_locale] & supported_locales).first || ([org.default_locale] & supported_locales).first || I18n.default_locale
  end

  def derive_organisation
    host = request.host
    if !user_signed_in? || current_user.organisation.nil?
      user_domain = ''
    else
      user_domain = current_user.organisation.domain      
    end
    
    match = /(www\.)?[a-z0-9]\.(.+)/.match(host) || []
    domain = match[2] || ''

    if domain.present?
      org = Organisation.find_by_domain(domain)
    end
    
    if org.blank? || org.id == dcc_organisation.try(:id)
      org = Organisation.find_by_domain(user_domain)
    end
    
    if org.try(:branded)
      org
    else
      dcc_organisation || Organisation.first
    end      
  end
  
  def derive_checklist_organisation
    OrganisationType.for_checklist.try(:organisations).try(:first) || Organisation.dcc.first
  end
end
