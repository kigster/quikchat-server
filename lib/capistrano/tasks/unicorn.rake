namespace :deploy do
  before :starting, :load_unicorn_hooks do
    after 'deploy:published', 'unicorn:restart'
  end
end

namespace :unicorn do
  desc 'Reload unicorn'
  task :reload do
    on roles(:app) do
      execute 'svcadm restart quikchat'
    end
  end

  desc 'Restarting unicorn'
  task :restart do
    on roles(:app), in: :sequence do
      execute 'sleep 10'
      execute 'svcadm disable -s quikchat'
      execute 'svcadm enable -s quikchat'
    end
  end

  desc 'Start unicorn'
  task :start do
    on roles(:app) do
      execute 'svcadm enable -s quikchat'
    end
  end

  desc 'Stop unicorn'
  task :stop do
    on roles(:app) do
      execute 'svcadm disable -s quikchat'
    end
  end
end
