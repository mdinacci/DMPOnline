class Devise::RecaptchaRegistrationsController < Devise::RegistrationsController 

  def create
    passed = !Rails.application.config.recaptcha_enabled
    
    if session[:omniauth].nil?
      if Rails.application.config.recaptcha_enabled
        passed = verify_recaptcha
        flash.delete :recaptcha_error
        if !passed
          flash[:error] = I18n.t('recaptcha.errors.incorrect-captcha-sol') 
        end
      end
      if params[:email] != params[:email_confirmation]
        if passed
          flash[:error] = I18n.t('dmp.auth.unmatched_email')
        end
        passed = false
      end
    end
    
    if !session[:omniauth].nil? || passed
      if using_shibboleth?
        pw = rand(36**8).to_s(36)
        params[resource_name][:password] = pw
        params[resource_name][:password_confirmation] = pw
      end
      
      super
      
      if using_shibboleth? && !@user.new_record?
        @user.update_attribute('shibboleth_id', session[:shibboleth_data][:uid])
        session[:omniauth] = nil
      end
    else
      build_resource 
      clean_up_passwords(resource)
      respond_with_navigational(resource) { render_with_scope :new }
    end 
  end 

  # Override the Devise update action to not update_with_password when we're using Shibboleth
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    result = if using_shibboleth?
      params[resource_name].delete(:current_password)
      params[resource_name].delete(:password)
      params[resource_name].delete(:password_confirmation)
      resource.update_without_password(params[resource_name])
    else
      resource.update_with_password(params[resource_name])
    end
    if result 
      set_flash_message :notice, :updated if is_navigational_format?
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords(resource)
      respond_with_navigational(resource){ render_with_scope :edit }
    end
  end

end 
