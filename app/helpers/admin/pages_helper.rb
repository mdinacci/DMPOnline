module Admin::PagesHelper

  def menu_options
    h = {}
    Page::MENU.each_with_index do |v, i| 
      h[v.humanize] = i
    end
    h
  end
  
  def page_type_options
    { 
      I18n.t('dmp.admin.page_type_landing') => 'landing',
      I18n.t('dmp.admin.page_type_menu') => 'menu'
    }
  end

end
