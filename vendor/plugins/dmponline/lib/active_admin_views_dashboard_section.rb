class ActiveAdmin::Views::DashboardSection < ActiveAdmin::Views::Panel
  include Rails.application.routes.url_helpers
  
  protected

  def title
    begin 
      I18n.t!("active_admin.sections.#{@section.name.to_s}") 
    rescue I18n::MissingTranslationData 
      @section.name.to_s.titleize 
    end       
  end

end