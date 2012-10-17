module ActiveAdmin::ViewHelpers  
  
  def supported_locales
    Rails.application.config.supported_locales || ['en']
  end

  def object_detail(item)
    if item.nil?
      I18n.t('dmp.admin.deleted_object')
    else
      case item.class.name.underscore.to_sym
      when :boilerplate_text
        if item.boilerplate_type == 'Mapping'
          l = edit_admin_mapping_path(item.boilerplate_id)
        else
          l = edit_admin_question_path(item.boilerplate_id)
        end
        link_to "#{item.boilerplate_type}: #{item.content.truncate(50)}", l
  
      when :currency, :document
        link_to item.name, polymorphic_path([:admin, item])

      when :template
        link_to "(#{item.organisation.short_name}) #{item.name}", polymorphic_path([:admin, item])
  
      when :edition
        if item.phase.try(:template).nil?
          item.edition
        else
          link_to item.edition, admin_edition_path(item)
        end
        
      when :guide
        if item.guidance_type == 'Mapping'
          l = edit_admin_mapping_path(item.guidance_id)
        else
          l = edit_admin_question_path(item.guidance_id)
        end
        link_to "#{item.guidance_type}: #{strip_tags(item.guidance).truncate(50)}", l
  
      when :mapping
        if item.question.nil?
          "##{item.id}"
        else
          link_to "#{strip_tags(item.question.question).truncate(30)} -> #{strip_tags(item.dcc_question.question).truncate(30)}", edit_admin_question_path(item.question)
        end
        
      when :organisation
        link_to item.full_name.truncate(30), admin_organisation_path(item)
  
      when :organisation_type, :page, :post
        link_to item.title, polymorphic_path([:admin, item])
  
      when :phase
        if item.template.nil?
          item.phase
        else
          link_to item.phase, admin_template_path(item.template)
        end
  
      when :question
        link_to strip_tags(item.question).truncate(50), admin_question_path(item)
  
      when :role
        t = "dmp.admin.roles.#{item.assigned.first.to_s}"
        link_to "#{item.user.try(:email)}: #{I18n.t(t)}", admin_role_path(item)
      
      else
        I18n.t('dmp.admin.unknown_object')
      end
    end
  end


  def stats_all_users
    hash = User
      .select("YEAR(created_at) AS year, MONTH(created_at) AS month, COUNT(*) AS tally")
      .group("YEAR(created_at), MONTH(created_at)")  
      .joins("LEFT OUTER JOIN (SELECT DISTINCT user_id FROM roles WHERE role_flags = 0#{2**User::ROLES.index('invisible')}) r ON users.id = r.user_id")
      .where("r.user_id IS NULL")
      .inject({}) do |h, u|
        h.merge!("#{u.month}#{u.year}" => u.tally)
      end

    start = User.minimum(:created_at)
    cumulative_by_month(start, hash)
  end

  def stats_active_users
    hash = User
      .select("YEAR(created_at) AS year, MONTH(created_at) AS month, COUNT(*) AS tally")
      .group("YEAR(created_at), MONTH(created_at)")  
      .where("confirmed_at IS NOT NULL")
      .joins("LEFT OUTER JOIN (SELECT DISTINCT user_id FROM roles WHERE role_flags = 0#{2**User::ROLES.index('invisible')}) r ON users.id = r.user_id")
      .where("r.user_id IS NULL")
      .inject({}) do |h, u|
        h.merge!("#{u.month}#{u.year}" => u.tally)
      end

    start = User.minimum(:created_at)
    cumulative_by_month(start, hash)
  end

  def stats_user_activity
    User
      .select("YEAR(last_sign_in_at) AS year, MONTH(last_sign_in_at) AS month, COUNT(*) AS tally")
      .where("last_sign_in_at IS NOT NULL")
      .group("YEAR(last_sign_in_at), MONTH(last_sign_in_at)")
      .joins("LEFT OUTER JOIN (SELECT DISTINCT user_id FROM roles WHERE role_flags = 0#{2**User::ROLES.index('invisible')}) r ON users.id = r.user_id")
      .where("r.user_id IS NULL")
      .inject([]) do |d, u|
        d << [Date.civil(u.year, u.month, 1).to_time.to_i * 1000 + 12 * 3600 * 1000, u.tally]
      end
  end

  def stats_plans
    hash = Plan
      .select("YEAR(created_at) AS year, MONTH(created_at) AS month, COUNT(*) AS tally")
      .group("YEAR(created_at), MONTH(created_at)")
      .joins("LEFT OUTER JOIN (SELECT DISTINCT user_id FROM roles WHERE role_flags = 0#{2**User::ROLES.index('invisible')}) r ON plans.user_id = r.user_id")
      .where("r.user_id IS NULL")
      .inject({}) do |h, p|
        h.merge!("#{p.month}#{p.year}" => p.tally)
      end

    start = Plan.minimum(:created_at)
    cumulative_by_month(start, hash)
  end

  def stats_multiple_template
    Plan
      .joins("INNER JOIN (SELECT plan_id, COUNT(*) AS template_count FROM template_instances GROUP BY plan_id) a ON a.plan_id = plans.id")
      .select("a.template_count, COUNT(*) AS tally")
      .group("a.template_count")
      .joins("LEFT OUTER JOIN (SELECT DISTINCT user_id FROM roles WHERE role_flags = 0#{2**User::ROLES.index('invisible')}) r ON plans.user_id = r.user_id")
      .where("r.user_id IS NULL")
      .inject([]) do |d, p|
        d << [p.template_count, p.tally]
      end
  end
  
  def stats_organisation_template_use
    hash = Organisation
      .joins(:templates => {:template_instances => :plan})
      .select("organisations.short_name, YEAR(template_instances.created_at) AS year, MONTH(template_instances.created_at) AS month, COUNT(*) AS tally")
      .joins("LEFT OUTER JOIN (SELECT DISTINCT user_id FROM roles WHERE role_flags = 0#{2**User::ROLES.index('invisible')}) r ON plans.user_id = r.user_id")
      .where("r.user_id IS NULL")
      .group("organisations.short_name, YEAR(template_instances.created_at), MONTH(template_instances.created_at)")
      .inject({}) do |h, o|
        h[o.short_name] ||= {}
        h[o.short_name].merge!("#{o.month}#{o.year}" => o.tally)
        h
      end
    
    start = Plan.minimum(:created_at)
    group_cumulative_by_month(start, hash)
  end

  def stats_user_counts
    User
      .select("COUNT(*) AS user_count, CASE WHEN confirmed_at IS NULL THEN 0 ELSE 1 END AS confirmed")
      .joins("LEFT OUTER JOIN (SELECT DISTINCT user_id FROM roles WHERE role_flags = 0#{2**User::ROLES.index('invisible')}) r ON users.id = r.user_id")
      .where("r.user_id IS NULL")
      .group("CASE WHEN confirmed_at IS NULL THEN 0 ELSE 1 END")
      .inject({}) do |h, u|
        if u.confirmed == 1
          h[:confirmed] = u.user_count
        else
          h[:unconfirmed] = u.user_count
        end
        h
      end
  end

  def stats_plan_count
    Plan
      .select("COUNT(*) AS plan_count")
      .joins("LEFT OUTER JOIN (SELECT DISTINCT user_id FROM roles WHERE role_flags = 0#{2**User::ROLES.index('invisible')}) r ON plans.user_id = r.user_id")
      .where("r.user_id IS NULL")
      .first
      .plan_count
  end
  
  def stats_template_counts
    t = Template
      .select("COUNT(templates.id) AS template_count, COUNT(p.template_id) AS published_count")
      .joins("LEFT OUTER JOIN (SELECT DISTINCT s.template_id FROM editions e INNER JOIN phases s ON s.id = e.phase_id WHERE e.status=#{Edition::STATUS.index('published')}) p ON p.template_id = templates.id")
      .first

    pvi = PhaseEditionInstance
      .select("DISTINCT template_instances.template_id")
      .joins(:template_instance => :plan)
      .joins("LEFT OUTER JOIN (SELECT DISTINCT user_id FROM roles WHERE role_flags = 0#{2**User::ROLES.index('invisible')}) r ON plans.user_id = r.user_id")
      .where("r.user_id IS NULL")
      
    { template_count: t.template_count, published_count: t.published_count, templates_used: pvi.count }
      
  end
  
  def stats_published_templates
    Template
      .joins(:phases => :editions)
      .joins(:organisation)
      .where("editions.status" => Edition::STATUS.index('published'))
      .select("DISTINCT templates.id, organisations.short_name AS org_name, templates.name")
  end

  def stats_org_users
    Organisation
      .joins(:users)
      .joins("LEFT OUTER JOIN (SELECT DISTINCT user_id FROM roles WHERE role_flags = 0#{2**User::ROLES.index('invisible')}) r ON users.id = r.user_id")
      .where("r.user_id IS NULL")
      .select("organisations.short_name AS org_name, COUNT(*) AS user_count")
      .group("organisations.id, organisations.short_name")
      .inject({}) do |h, o|
        h[:data] ||= []
        h[:data] << [o.org_name, o.user_count]
        h[:categories] ||= []
        h[:categories] << o.org_name
        h
      end
  end


  protected
  
  def cumulative_by_month(start, hash)
    data = []
    
    if start.present?
      tally_date = Date.new(start.year, start.month, 1)
      range_end = Date.today
      total = 0
      
      loop do
        total += hash["#{tally_date.month}#{tally_date.year}"].to_i
        
        tally_date += 1.month
        data << [Date.civil(tally_date.year, tally_date.month, 1).to_time.to_i * 1000 + 12 * 3600 * 1000, total]
        
        break if tally_date + 1.month > range_end
      end
    end
    
    data
  end

  def group_cumulative_by_month(start, hash)
    data = []
    hash.each do |n, d|
      data << {name: n, data: cumulative_by_month(start, d)}
    end
    
    data
  end
    

end
