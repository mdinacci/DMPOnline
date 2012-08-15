class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def shibboleth
    if user_signed_in? && !current_user.shibboleth_id.blank?
      flash[:warning] = I18n.t('devise.failure.already_authenticated')
      redirect_to frontpage
    else
      auth = request.env['omniauth.auth'] || {}
      eppn = auth['extra']['raw_info']['eppn']
      uid = eppn.blank? ? auth['uid'] : eppn        
      
      @user = uid.blank? ? current_user : User.where(shibboleth_id: uid).first

      if @user.persisted?
        flash[:notice] = I18n.t('devise.omniauth_callbacks.success', :kind => 'Shibboleth')
        sign_in_and_redirect @user, event: :authentication
      else
        if user_signed_in?
          # Reset user password so they can only log in with shibboleth in the future
          pw = rand(36**8).to_s(36)
          user.update_attributes(shibboleth_id: uid, password: pw)
          flash[:notice] = I18n.t('dmp.auth.password_reset_shib')
        else
          session[:shibboleth_data] = request.env['omniauth.auth']
          session[:shibboleth_data][:uid] = uid
          redirect_to new_user_registration_url
        end
      end
    end
  end
  
end