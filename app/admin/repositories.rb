ActiveAdmin.register Repository do
  menu priority: 10

  # Limit list according to access rights
  scope_to :current_user
  
  filter :name
  filter :organisation
  filter :sword_collection_uri
  
  controller do 
    authorize_resource

    def show
      if params[:version] && params[:version].to_i > 0
        @repository = Repository.find(params[:id]).versions[params[:version].to_i - 1].try(:reify)
      end
      show!
    end

    def create
      @repository = Repository.new
      @repository.assign_attributes(params[:repository])
      
      if eligible_organisation(@repository)
        create!
      else
        edit!
      end
    end
    
    def update
      if eligible_organisation(resource)
        update!
      else
        @repository.assign_attributes(params[:repository])
        edit!
      end
    end
    
    def destroy
      @repository = Repository.find(params[:id])
      @repository.destroy
      respond_to do |format| 
        if @repository.errors[:base].present?
          flash.now[:error] = @repository.errors[:base].to_sentence
          format.html { render action: 'show' }
        else
          flash[:notice] = I18n.t('dmp.admin.model_destroyed', model: I18n.t('activerecord.models.repository.one'))
          format.html { redirect_to admin_repositories_url }
        end
      end
    end

    private
    
    def eligible_organisation(template)
      ok = true
      
      if !current_user.org_list.collect(&:id).include?(params[:repository][:organisation_id].to_i)
        ok = false
        template.errors.add(:organisation_id, I18n.t('dmp.admin.bad_selection'))
      end
      ok
    end
  end
  
    
  sidebar :versions, partial: 'admin/shared/version', :only => :show
  member_action :history do
    @repository = Repository.find(params[:id])
    @page_title = I18n.t('dmp.admin.item_history', item: @repository.name)
    render "admin/shared/history"
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.edit_model', model: I18n.t('activerecord.models.repository.one')), edit_admin_repository_path(repository)
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.details', model: I18n.t('activerecord.models.repository.one')), admin_repository_path(repository)
  end

  form :title => :name, :partial => "form"
  
  index do
    column :name
    column :organisation
    column :sword_collection_uri
    column :username
    column :administrator_email
    if metadata_option_available?  
      column :create_metadata_with_new_plan do |r|
        check_box_tag :create_metadata_with_new_plan, 1, r.create_metadata_with_new_plan, :disabled=>true
      end
    end
    default_actions
  end

  show :title => :name do |repository|
    div do
      render :partial => "show", :locals => {:repository => repository, :filetypes => export_formats_collection}
    end
    active_admin_comments
  end

end
