# config valid only for Capistrano 3.1
lock '3.2.1'

SSHKit.config.command_map[:rake] = 'bundle exec rake'

set :application, 'quikchat-server'
set :repo_url, 'git@github.com:kigster/quikchat-server.git'
set :deploy_to, '/home/quikchat/app'
set :branch, ENV['BRANCH_NAME'] || 'master'

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
