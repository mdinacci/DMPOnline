ActiveAdmin.register Currency do
  menu if: proc{ current_user.is_dccadmin? }, priority: 2

  controller do 
    authorize_resource

    def show
      if params[:version] && params[:version].to_i > 0
        @currency = Currency.find(params[:id]).versions[params[:version].to_i - 1].try(:reify)
      end
      show!
    end

    def destroy
      @currency = Currency.find(params[:id])
      @currency.destroy
      respond_to do |format| 
        if @currency.errors[:base].present?
          flash.now[:error] = @currency.errors[:base].to_sentence
          format.html { render action: 'show' }
        else
          flash[:notice] = I18n.t('dmp.admin.model_destroyed', model: I18n.t('activerecord.models.currency.one'))
          format.html { redirect_to admin_currencies_url }
        end
      end
    end
    
  end

  sidebar :versions, partial: 'admin/shared/version', :only => :show  
  member_action :history do
    @currency = Currency.find(params[:id])
    @page_title = I18n.t('dmp.admin.item_history', item: @currency.name)
    render "admin/shared/history"
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.edit_model', model: I18n.t('activerecord.models.currency.one')), edit_admin_currency_path(currency)
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.details', model: I18n.t('activerecord.models.currency.one')), admin_currency_path(currency)
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :iso_code
      f.input :symbol
    end
    
    f.buttons
  end

  show :title => :name do |c|
    attributes_table do
      row :name
      row :iso_code
      row :symbol
    end
    active_admin_comments
  end

  index do 
    column :name
    column :iso_code
    column :symbol
    default_actions
  end

end
