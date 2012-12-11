class Notifier < ActionMailer::Base
  #default from: noreply@example.com 
  
  def plan_shared(email, sender, plan)
    @plan = plan
    @sender = sender
    mail to: email, subject: I18n.t('dmp.notify.plan_shared'), from: sender
  end 

  def report_queue_error(repository_queue_entry, exception = nil)
    @entry = repository_queue_entry
    @exception = exception
    
    mail  to: repository_queue_entry.repository.administrator_email, 
          subject: I18n.t('repository.notify.queue_error'),
          from: Rails.application.config.repository_notifications_from
  end

end
