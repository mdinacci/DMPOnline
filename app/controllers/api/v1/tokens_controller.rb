class Api::V1::TokensController < ApplicationController
  respond_to :xml
  skip_before_filter :verify_authenticity_token

  # POST api/v1/authenticate
  def create
    @token = ''
    @error = ''
    status = :ok
    email = params[:email]
    password = params[:password]
    if current_user
      sign_out current_user
    end

    if email.blank? || password.blank?
      status = :bad_request
      @error = "Bad request"
      
    else
      user = User.find_by_email(email)
  
      if user.nil?
        logger.info "API: User #{email} not found."
        status = :not_found
        @error = "Not found"        

      else
        if user.valid_password?(password)
          sign_in user, force: true
          user.token_created_at = Time.now
          user.reset_authentication_token!
          @token = user.authentication_token
        else
          logger.info "API: User #{email} login failed"
          status = :not_found
          @error = "Not found"
        end
      end
    end

    render status: status, layout: false
  end

  # DELETE api/v1/authenticate
  def destroy
    token = params[:api_key]
    status = :ok
    @token = ''
    @error = ''
    if current_user
      sign_out current_user
    end
    
    if token.blank?
      status = :bad_request
      @error = 'Bad request'

    else
      user = User.find_by_authentication_token(token)
      
      if user.nil?
        logger.info 'API: Token not found.'
        status = :not_found
        @error = 'Not found'
      else
        user.token_created_at = nil
        user.reset_authentication_token!
      end
    end

    render :create, status: status, layout: false
  end

end
