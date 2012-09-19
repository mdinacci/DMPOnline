class Notifier < ActionMailer::Base
  #default from: noreply@example.com 
  
  def plan_shared(email, sender, plan)
    @plan = plan
    @sender = sender
    mail to: email, subject: I18n.t('dmp.notify.plan_shared'), from: sender
  end 
end
