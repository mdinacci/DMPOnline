module Admin::RolesHelper

  def role_options
    h = {}
    User::ROLES.each_with_index do |r, i| 
      h[I18n.t("dmp.admin.roles.#{r.to_s}")] = 2 ** i
    end
    h
  end

  def edition_options
    h = {}
    Edition.includes(:phase => {:template => :organisation}).order("organisations.short_name, templates.name, phases.position, editions.created_at").each do |v|
      unless v.phase.try(:template).nil?
        h["#{v.phase.template.organisation.short_name}: #{v.phase.template.name}, #{v.phase.phase} (#{v.edition})"] = v.id
      end
    end
    h
  end

end
