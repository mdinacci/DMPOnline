ActiveAdmin.register Post do
  # Limit list according to access rights
  scope_to :current_user
  
  filter :organisation
  filter :created_at, :as => :date_range

  scope :all, :default => true
  Rails.application.config.supported_locales.each do |l|
    scope l do |posts|
      posts.where(:locale => l.to_s)
    end
  end

  controller do 
    authorize_resource

    def create 
      create! do |format|
         format.html { redirect_to admin_posts_path } 
      end 
    end 

    def show
      if params[:version] && params[:version].to_i > 0
        @post = Post.find(params[:id]).versions[params[:version].to_i - 1].try(:reify)
      end
      show!
    end
  end

  sidebar :versions, partial: 'admin/shared/version', :only => :show
  member_action :history do
    @post = Post.find(params[:id])
    @page_title = I18n.t('dmp.admin.item_history', item: @post.title)
    render "admin/shared/history"
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.edit_model', model: I18n.t('activerecord.models.post.one')), edit_admin_post_path(post)
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.details', model: I18n.t('activerecord.models.post.one')), admin_post_path(post)
  end

  form :title => :title, :partial => "form"

  show :title => :title do |post|
    attributes_table do
      row :title
      row :body do 
        sanitize post.body
      end
      row :locale
      row :organisation
    end
    
    active_admin_comments
  end

  index do |post|
    column :title
    column :locale
    column :organisation
    default_actions
  end

end
