# encoding: UTF-8

include Rails.application.routes.url_helpers

OrganisationType.create!(:title => 'Funding Bodies')
institution = OrganisationType.create!(:title => 'Institutions')
OrganisationType.create!(:title => 'Disciplines')
 
dcc = Organisation.create!(
  :full_name => "Digital Curation Centre",
  :short_name => "DCC",
  :domain => "dcc.ac.uk",
  :organisation_type_id => institution.id,
  :url => "www.dcc.ac.uk",
  :default_locale => 'en'
)
org = Organisation.create!(
  :full_name => "The University of Edinburgh",
  :short_name => "UoE",
  :domain => "ed.ac.uk",
  :url => "www.ed.ac.uk",
  :organisation_type_id => institution.id,
  :default_locale => 'en'
)

#
# t = Template.create!(
#   :organisation_id => dcc.id,
#   :name => "DCC Checklist",
#   :phases_attributes => [{:phase => "Checklist", :position => 1 }]
# )
# t.make_checklist(dcc.id)
#

# 
# Load DCC Checklist from SQL file
#
conn = ActiveRecord::Base.connection()
sql = File.read("#{Rails.root}/db/checklist.sql")
sql.split("\n").each do |line|
  conn.execute line
end

Page.create!([
  {
    :title => "Welcome to DMP Online",
    :body => "This is the default homepage",
    :slug => "home",
    :position => 0,
    :menu => Page::MENU.index('none'),
    :page_type => 'landing',
    :organisation_id => dcc.id
  },
  {
    :title => "Privacy Statement/Terms of Use",
    :body => "<p>This software is made available under ... licence.</p><p>No warranty...</p>",
    :slug => "terms",
    :position => 1,
    :menu => Page::MENU.index('help'),
    :page_type => 'landing',
    :organisation_id => dcc.id
  },
  {
    :title => "Help",
    :body => "<p>dmponline@dcc.ac.uk</p>",
    :slug => "help",
    :position => 2,
    :menu => Page::MENU.index('help'),
    :page_type => 'landing',
    :organisation_id => dcc.id
  },
  {
    :title => "Home",
    :menu => Page::MENU.index('navigation'),
    :position => -10,
    :target_url => root_path,
    :page_type => 'menu',
    :organisation_id => dcc.id
  },
  {
    :title => "My Plans",
    :menu => Page::MENU.index('navigation'),
    :position => 10,
    :target_url => plans_path,
    :page_type => 'menu',
    :organisation_id => dcc.id
  },
  {
    :title => "Shared Plans",
    :menu => Page::MENU.index('navigation'),
    :position => 10,
    :target_url => shared_plans_path,
    :page_type => 'menu',
    :organisation_id => dcc.id
  }
])

Currency.create!([
  {
    :name => "Pound Sterling",
    :symbol => "£",
    :iso_code => "GBP"
  },
  {
    :name => "Euro",
    :symbol => "€",
    :iso_code => "EUR"
  }
])

user = User.new
user.send :attributes=, {:email => 'admin@example.com', :email_confirmation => 'admin@example.com', :password => 'password', :password_confirmation => 'password', :confirmed_at => Time.current}, false
user.save!

role = Role.new
role.user_email = user.email
role.assigned= :sysadmin
role.save!

user = User.new
user.send :attributes=, {:email => 'dcc@example.com', :email_confirmation => 'dcc@example.com', :password => 'password', :password_confirmation => 'password', :confirmed_at => Time.current}, false
user.save!

role = Role.new
role.user_email = user.email
role.assigned= :dccadmin
role.save!

user = User.new
user.send :attributes=, {:email => 'organisation@example.com', :email_confirmation => 'organisation@example.com', :password => 'password', :password_confirmation => 'password', :confirmed_at => Time.current}, false
user.save!

role = Role.new
role.user_email = user.email
role.organisation_id = org.id
role.assigned= :orgadmin
role.save!

user = User.new
user.send :attributes=, {:email => 'user@example.com', :email_confirmation => 'user@example.com', :password => 'password', :password_confirmation => 'password', :confirmed_at => Time.current}, false
user.save!
