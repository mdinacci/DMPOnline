ActiveAdmin.register Page do
  menu :priority => 6
  
  # Limit list according to access rights
  scope_to :current_user
  
  filter :organisation
  filter :menu, :as => :select, :collection => Page::MENU
  
  scope :all, :default => true
  Rails.application.config.supported_locales.each do |l|
    scope l do |pages|
      pages.where(:locale => l.to_s)
    end
  end

  controller do 
    authorize_resource

    def show
      if params[:version] && params[:version].to_i > 0
        @page = Page.find(params[:id]).versions[params[:version].to_i - 1].try(:reify)
      end
      show!
    end

    def create 
      create! do |format|
         format.html { redirect_to admin_pages_path } 
      end 
    end
  end 

  sidebar :versions, partial: 'admin/shared/version', :only => :show
  member_action :history do
    @page = Page.find(params[:id])
    @page_title = I18n.t('dmp.admin.item_history', item: @page.title)
    render "admin/shared/history"
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.edit_model', model: I18n.t('activerecord.models.page.one')), edit_admin_page_path(page)
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.details', model: I18n.t('activerecord.models.page.one')), admin_page_path(page)
  end

  form :title => :title, :partial => "form"

  show :title => :title do |page|
    attributes_table do
      row :title
      row :body do
        sanitize page.body
      end
      row :slug
      row :menu do
        Page::MENU[page.menu].humanize unless page.menu.nil?
      end
      row :position
      row :target_url
      row :organisation
      row :locale
    end
    
    active_admin_comments
  end

  index do 
    column :title
    column :slug
    column :menu do |page|
      Page::MENU[page.menu].humanize unless page.menu.nil?
    end
    column :target_url
    column :organisation
    column :locale
        
    default_actions
  end

end
