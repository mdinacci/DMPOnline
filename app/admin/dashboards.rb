ActiveAdmin::Dashboards.build do
  # Define your dashboard sections here. Each block will be
  # rendered on the dashboard in the context of the view. So just
  # return the content which you would like to display.
  
  # == Simple Dashboard Section
  # Here is an example of a simple dashboard section
  #
  #   section "Recent Posts" do
  #     ul do
  #       Post.recent(5).collect do |post|
  #         li link_to(post.title, admin_post_path(post))
  #       end
  #     end
  #   end
  
  # == Render Partial Section
  # The block is rendered within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     div do
  #       render 'recent_posts' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #     end
  #   end
  
  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section "Recent Posts", :priority => 10
  #   section "Recent User", :priority => 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.

  section :reporting, priority: 1 do
    dl class: "checklist" do
      dt "#{I18n.t("dmp.admin.stats.current_checklist")}: "

      c = Template.dcc_checklist
      if c.present?
        v = c.editions.where(:status => Edition::STATUS.index('published')).first
      
        dd do
          span "#{c.name} (#{c.organisation.full_name})"
          if v.nil?
            span I18n.t('dmp.admin.none'), class: "empty"
          else
            span link_to v.edition, admin_edition_path(v)
          end
        end
      else
        dd I18n.t('active_admin.empty'), class: "warning_message"
      end
    end

    div do
      t = stats_template_counts
      u = stats_user_counts
      ul class: "figures" do
        li do
          span "#{I18n.t("dmp.admin.stats.confirmed_user_count")}: "
          span u[:confirmed], class: "figure"
        end
        li do
          span "#{I18n.t("dmp.admin.stats.unconfirmed_user_count")}: "
          span u[:unconfirmed], class: "figure"
        end
        li do
          span "#{I18n.t("dmp.admin.stats.plan_count")}: "
          span stats_plan_count, class: "figure"
        end
        li do
          span "#{I18n.t("dmp.admin.stats.template_count")}: "
          span t[:template_count], class: "figure"
        end
        li do
          span "#{I18n.t("dmp.admin.stats.templates_used")}: "
          span t[:templates_used], class: "figure"
        end
        li do
          span "#{I18n.t("dmp.admin.stats.published_count")}: "
          span t[:published_count], class: "figure"
        end
        li do
          span "#{I18n.t("dmp.admin.stats.organisation_count")}: "
          span Organisation.all.count, class: "figure"
        end
      end
    end
  end

  section :published_templates, priority: 2 do
    div do
      ul class: "templates" do
        stats_published_templates.each do |t|
          li link_to "#{t.name} (#{t.org_name})", admin_template_path(t.id)
        end
      end
    end
  end
  
  section :activity, priority: 3 do
    div do
      series = [{label: I18n.t('dmp.admin.stats.plans_report'), data: 'stats_plans'},
                {label: I18n.t('dmp.admin.stats.users_report'), data: 'stats_active_users'}]
      render partial: "chart", 
             locals: {report_title: I18n.t('dmp.admin.stats.users_plans'), 
                      x_axis_title: '', 
                      y_axis_title: '', 
                      series: series,
                      categories: nil,
                      chart_type: 'line',
                      zoom_type: 'xy',
                      legend_side: false,
                      x_type: 'datetime',
                      x_interval: 365.25 * 24 * 3600 * 1000 / 12,
                      y_type: 'linear'}
    end
  end

  section :activity, priority: 4 do
    div do
      series = stats_organisation_template_use
      
      render partial: "chart", 
             locals: {report_title: I18n.t('dmp.admin.stats.organisation_report'), 
                      x_axis_title: '', 
                      y_axis_title: I18n.t('dmp.admin.stats.plans_using_template'), 
                      series: series,
                      categories: nil,
                      chart_type: 'line',
                      zoom_type: 'xy',
                      legend_side: true,
                      x_type: 'datetime',
                      x_interval: 365.25 * 24 * 3600 * 1000 / 12,
                      y_type: 'linear'}
    end
  end

  section :activity, priority: 5 do
    div do
      series = [{label: I18n.t('dmp.admin.stats.plan_count'), data: 'stats_multiple_template'}]
      render partial: "chart",
             locals: {report_title: I18n.t('dmp.admin.stats.template_report'), 
                      x_axis_title: I18n.t('dmp.admin.stats.templates_used'), 
                      y_axis_title: I18n.t('dmp.admin.stats.plan_count'), 
                      series: series,
                      categories: nil,
                      chart_type: 'column',
                      legend_side: false,
                      zoom_type: 'x',
                      x_type: 'linear',
                      x_interval: 1,
                      y_type: 'linear'}
    end   
  end

  section :activity, priority: 6 do
    div do
      series = [{label: I18n.t('dmp.admin.stats.user_activity_report'), data: 'stats_user_activity'}]
      render partial: "chart", 
             locals: {report_title: I18n.t('dmp.admin.stats.user_activity_report'), 
                      x_axis_title: I18n.t('dmp.admin.stats.last_signed_in'),
                      y_axis_title: I18n.t('dmp.admin.stats.user_count'),
                      series: series,
                      categories: nil,
                      chart_type: 'column',
                      legend_side: false,
                      zoom_type: 'x',
                      x_type: 'datetime', 
                      x_interval: 365.25 * 24 * 3600 * 1000 / 12,
                      y_type: 'linear'}
    end   
  end

  section :activity, priority: 7 do
    div do
      series = stats_org_users
      series_data = [{name: I18n.t('dmp.admin.stats.org_users_report'), data: series[:data]}]
      render partial: "chart", 
             locals: {report_title: I18n.t('dmp.admin.stats.org_users_report'), 
                      x_axis_title: I18n.t('dmp.admin.stats.organisation'),
                      y_axis_title: I18n.t('dmp.admin.stats.user_count'),
                      series: series_data,
                      categories: series[:categories],
                      chart_type: 'bar',
                      legend_side: false,
                      zoom_type: 'x',
                      x_type: 'linear',
                      x_interval: 1,
                      y_type: 'linear'}
    end
  end

  section :paper_trail, priority: 8 do
    table_for Version.order('id desc').limit(20) do
      column I18n.t('dmp.admin.stats.type') do |v| "#{v.event.titlecase} #{v.item_type.underscore.humanize}" end
      column I18n.t('dmp.admin.stats.item') do |v| object_detail(v.item) end
      column I18n.t('dmp.admin.stats.modified_at') do |v| v.created_at.to_s :medium end
      column I18n.t('dmp.admin.stats.user') do |v| User.where(id: v.whodunnit).first.try(:email) end
    end
  end

end

