before 'deploy:updated', 'bundler:install'

namespace :bundler do
  task :install do
    on release_roles(:app) do
      within release_path do
        execute "bin/bundle", "install --standalone --path vendor/bundle --without development test --deployment --quiet"
      end
    end
  end
end
