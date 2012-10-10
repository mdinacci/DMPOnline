ActiveAdmin.register Document do
  menu :priority => 8

  # Limit list according to access rights
  scope_to :current_user

  filter :organisation
  filter :visible, :as => :select, :collection => [['Yes', 1], ['No', 0]]
  
  scope :all, :default => true
  Rails.application.config.supported_locales.each do |l|
    scope l do |docs|
      docs.where(:locale => l.to_s)
    end
  end

  controller do 
    authorize_resource

    def show
      if params[:version] && params[:version].to_i > 0
        @document = Document.find(params[:id]).versions[params[:version].to_i - 1].try(:reify)
      end
      show!
    end

    def create
      @document = Document.new
      @document.assign_attributes(params[:document])
      
      if eligible_organisation(@document)
        create!
      else
        edit!
      end
    end
    
    def update
      if eligible_organisation(resource)
        update!
      else
        @document.assign_attributes(params[:document])
        edit!
      end
    end

    private
    
    def eligible_organisation(document)
      ok = true
      
      if !current_user.org_list.collect(&:id).include?(params[:document][:organisation_id].to_i)
        ok = false
        document.errors.add(:organisation_id, I18n.t('dmp.admin.bad_selection'))
      end
      ok
    end
  end

  sidebar :versions, partial: 'admin/shared/version', :only => :show
  member_action :history do
    @document = Document.find(params[:id])
    @page_title = I18n.t('dmp.admin.item_history', item: @document.name)
    render "admin/shared/history"
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.edit_model', model: I18n.t('activerecord.models.document.one')), edit_admin_document_path(document)
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.details', model: I18n.t('activerecord.models.document.one')), admin_document_path(document)
  end
  
  form :html => {:multipart => true}, :title => :title, :partial => "form"

  show :title => :name do |document|
    attributes_table do
      row I18n.t('dmp.admin.download') do
        link_to image_tag(document.icon.url(:thumb), :align => :left, :border => 0), document.attachment.url
      end
      row :attachment_file_size
      row :attachment_updated_at
      row :name
      row :edition
      row :description do 
        sanitize document.description
      end
      row :visible
      row :position
      row :organisation
      row :locale

    end
    
    active_admin_comments
  end

  index do 
    column :position
    column I18n.t('dmp.admin.download') do |document|
      link_to image_tag(document.icon.url(:thumb), :align => :left, :border => 0), document.attachment.url if document.icon.file?
    end
    column I18n.t('formtastic.labels.document.name') do |document| 
      link_to document.name, document.attachment.url
    end
    column :edition
    column :attachment_updated_at
    column :visible
    column :organisation
    default_actions
  end

end
