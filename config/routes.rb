class BlockToken
  def matches?(request) 
    !request.params.has_key?(:api_key) 
  end
end


Dmponline3::Application.routes.draw do

  constraints BlockToken.new do 
    ActiveAdmin.routes(self)
    
    devise_for :users, {
      :sign_out_via => [ :post, :delete, :get ],
      :path_names => { :sign_in => 'login', :sign_out => 'logout' },
      :controllers => { 
        :registrations => 'devise/recaptcha_registrations', 
        :omniauth_callbacks => 'users/omniauth_callbacks',
        },
      }
    # WAYFless access point - use query param idp
    get 'auth/shibboleth' => 'users/omniauth_shibboleth_request#redirect', :as => 'user_omniauth_shibboleth'
    get 'auth/shibboleth/assoc' => 'users/omniauth_shibboleth_request#associate', :as => 'user_shibboleth_assoc'

    get 'pages/:slug' => 'pages#show', :as => 'pages_slug'
    get '' => 'pages#frontpage', :as => 'frontpage'
    get 'news/:id' => 'posts#show', :as => 'post'
    get 'news' => 'posts#index', :as => 'posts'
    get 'documents' => 'documents#index', :as => 'documents'
    
    resources :plans do
      collection do
        get 'shared'
      end
      member do
        post 'duplicate'
        put 'lock'
        put 'unlock'
        get 'complete'
        get 'output'
        get 'section/:section_id', :action => 'ajax_section', :as => 'ajax_section', :section_id => /\d+/
        put 'phase/:edition_id/set', :action => 'change_phase', :as => 'change_phase', :edition_id => /\d+/
        get 'rights'
        put 'update_rights'
        put 'notify/:template_instance_right_id', :action => 'notify', :as => 'notify', :template_instance_right_id => /\d+/
      end
  
      resources :phase_edition_instances, :only => [:update], :as => "layer", :path => 'layer' do
        member do
          get 'checklist/:question_id', :question_id => /\d+/, :action => 'checklist', :as => 'checklist'
          post 'add_answer/:question_id', :question_id => /\d+/, :action => 'add_answer', :as => 'add_answer'
          delete 'drop_row/:question_id/:drop_row', :question_id => /\d+/, :drop_row => /\d+/, :action => 'drop_row', :as => 'drop_row'
          get 'output'
          get 'output_all'
          # Changed to POST - IE apparently not happy with long URLs and plugins
          post 'export'
        end
      end
    end
    
  end

  namespace :api, defaults: { format: 'xml' }, constraints: { format: 'xml' } do
    namespace :v1 do
      post 'authenticate' => 'tokens#create'
      delete 'authenticate' => 'tokens#destroy'
      resources :editions, only: [:show, :index], path: 'templates' do
        member do
          get 'users', action: 'users'
          get 'usersCERIF', action: 'usersCERIF'
        end
        resources :phase_edition_instances, only: [:show, :index], path: 'instances', as: 'instances'
        resources :answers, only: [:index, :update], path: 'answers', as: 'answers'
      end
      post 'templates/:edition_id' => 'plans#create', :edition_id => /\d+/
    end
  end
  
  root :to => 'pages#frontpage'

end
