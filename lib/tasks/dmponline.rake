namespace :dmponline do

  desc "This processes the repository action queue, run this on a scheduled basis via cron, say every ~20 minutes."
  task :repository => :environment do
    RepositoryActionQueue.process
  end

end