ActiveAdmin.register Edition do
  menu false
  config.clear_sidebar_sections!
  config.clear_action_items!
  scope_to :current_user
  
  action_item :only => :show do
    link_to(I18n.t('dmp.admin.edit_edition_sort_questions'), edit_admin_edition_path(edition))
  end

  action_item :only => :edit do
    link_to(I18n.t('dmp.admin.edition_detail'), admin_edition_path(edition))
  end
  
  action_item :only => :show do
    case edition.state
    when :unpublished
      link_to(I18n.t('dmp.admin.publish'), publish_admin_edition_path(edition))
    when :published
      link_to(I18n.t('dmp.admin.unpublish'), unpublish_admin_edition_path(edition))
    end
  end

  
  controller do
    authorize_resource

    # This code is evaluated within the controller class
    # Access the Question helper methods
    helper :questions

    def new
      # Do nothing
      redirect_to admin_templates_path
    end

    def show
      if params[:version] && params[:version].to_i > 0
        @edition = Edition.find(params[:id]).versions[params[:version].to_i - 1].try(:reify)
      end
      show!
    end
  end

  sidebar :versions, partial: 'admin/shared/version', :only => :show
  member_action :history do
    @edition = Edition.find(params[:id])
    @page_title = I18n.t('dmp.admin.item_history', item: "#{@edition.phase.template.name}, #{@edition.phase.phase} (#{@edition.edition})")
    render "admin/shared/history"
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.edit_model', model: I18n.t('activerecord.models.edition.one')), edit_admin_edition_path(edition)
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.details', model: I18n.t('activerecord.models.edition.one')), admin_edition_path(edition)
  end

  form :title => :edition, :partial => "form"
  
  index do
    # We don't want anyone to reach this...
    controller.redirect_to admin_templates_path
  end
  
  show :title => proc { "#{edition.phase.template.organisation.full_name}" } do |edition|
    h2 "#{edition.phase.template.name} - #{edition.phase.phase}" 
    attributes_table do 
      row :edition
      row :dcc_edition do
        checklist = edition.dcc_edition.try(:edition) || ''
        warn = ''
        org_checklist = edition.phase.template.organisation.dcc_edition_id || dcc_organisation.dcc_edition_id
        if edition.dcc_edition_id != org_checklist && edition.dcc_edition.state != :published
          warn = content_tag(:span, I18n.t('dmp.admin.warn_checklist_not_published'), class: "warning").html_safe
        end
        sanitize checklist + warn
      end
      row :status do
        status_tag(edition.state.to_s)
      end
    end

    q_set = edition.questions.nested_set.all
    number_questions(q_set)
    dcc_numbers = dcc_numbering(edition)

    table_for(q_set) do |q|
      q.column(t('dmp.admin.number'), :number_display)
      q.column(t('dmp.template_question')) {|question| sanitize question.question }
      q.column(t('attributes.kind')) {|question| question_type_title(question.kind) }
      q.column(t('attributes.guidance')) {|question| sanitize question.guide.try(:guidance) }
      q.column(t('activerecord.models.boilerplate_text.other')) do |question|
        question.boilerplate_texts.each do |bp| 
          div bp_format(bp.content), class: "boilerplate"
        end
      end
      q.column(t('activerecord.models.mapping.other')) do |question|
        if question.mappings.count > 0
          table_for(question.mappings.all) do |m|
            m.column(t('attributes.dcc_question_id')) do |mapping| 
              div "DCC #{dcc_numbers[mapping.dcc_question.id]}", class: "dcc_question" 
              div sanitize(mapping.dcc_question.question)
            end
            m.column(t('attributes.guidance')) {|mapping| sanitize mapping.guide.try(:guidance) }
            m.column(t('activerecord.models.boilerplate_text.other')) do |mapping|
              mapping.boilerplate_texts.each do |bp| 
                div bp_format(bp.content), class: "boilerplate"
              end
            end
          end
        end
      end
      q.column(t('dmp.admin.actions')) do |question|
        link_to t('dmp.admin.edit'), edit_admin_question_path(question), class: "edit_link"
      end
    end

    # active_admin_comments
  end
  
  member_action :copy do
    edition = Edition.find(params[:id])

    new = edition.dup
    new.edition = (Float(edition.edition) + 0.01).to_s rescue DateTime.current.to_s(:db)
    new.state= :unpublished
    new.save!

    id_table = {}
    edition.questions.nested_set.each do |q|
      newq = q.dup
      newq.edition_id = new.id
      unless q.parent_id.nil?
        newq.parent_id = id_table[q.parent_id]
      end
      newq.save!
      id_table[q.id] = newq.id
      q.mappings.each do |m|
        newm = m.dup
        newm.question_id = newq.id
        newm.save!
      end
    end

    redirect_to edit_admin_edition_path(new)
  end

  member_action :generate do
    edition = Edition.find(params[:id])

    new = Edition.new
    new.phase_id = edition.phase_id
    new.edition = (Float(edition.edition) + 0.01).to_s rescue DateTime.current.to_s(:db)
    new.state= :unpublished
    new.save!

    redirect_to edit_admin_edition_path(new)
  end

  member_action :publish do
    edition = Edition.find(params[:id])
    
    edition.publish
    redirect_to admin_template_path(edition.phase.template)    
  end
  
  member_action :unpublish do
    edition = Edition.find(params[:id])
    
    edition.unpublish
    redirect_to admin_template_path(edition.phase.template)
  end

 
end
