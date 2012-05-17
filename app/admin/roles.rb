ActiveAdmin.register Role do
  menu :if => proc{ current_user.is_dccadmin? }

  scope :system_admins, :default => true do |roles|
    roles.with_role(:sysadmin)
  end
  scope :organisation_admins do |roles|
    roles.with_role(:orgadmin)
  end
  scope :api_access do |roles|
    roles.with_role(:apifull)
  end

  filter :organisation

  controller do 
    authorize_resource

    def create 
      create! do |format|
         format.html { redirect_to admin_roles_path } 
      end 
    end 
  end 
  
  
  form :partial => "form"

  show :title => :user_email do |role|
    attributes_table do
      row :email do
        role.user.email
      end
      row :assigned do
        role.assigned.collect{ |a| I18n.t("dmp.admin.roles.#{a}") }.join(', ')
      end
      row :organisation
      row :edition do
        v = role.edition
        unless v.nil?
          link_to "#{v.phase.template.organisation.short_name}: #{v.phase.template.name}, #{v.phase.phase} (#{v.edition})", admin_edition_path(v)
        end
      end
    end
    # active_admin_comments
  end

  index do 
    column :user
    column :assigned do |role|
      role.assigned.collect{ |a| I18n.t("dmp.admin.roles.#{a}") }.join(', ')
    end
    column :organisation
    column :template do |role|
      v = role.edition
      unless v.nil?
        link_to "#{v.phase.template.organisation.short_name}: #{v.phase.template.name}, #{v.phase.phase} (#{v.edition})", admin_edition_path(v)
      end
    end
    
    default_actions
  end

end
