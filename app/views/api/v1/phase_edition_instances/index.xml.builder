xml.instruct!
xml.dmponline do
  unless @error.blank?
    xml.error(@error)
  end

  xml.template_instances do
    @phase_edition_instances.each do |pei|
      xml.template_instance("instance_key" => pei.id, "edition_key" => pei.edition_id) do
        xml.user(pei.template_instance.plan.user.try(:email)) 
        xml.plan(pei.template_instance.plan.project, "plan_key" => pei.template_instance.plan.id)
        xml.url()
      end
    end
  end
end