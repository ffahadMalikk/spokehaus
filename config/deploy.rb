# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'spokehaus.ca'
set :repo_url, 'git@github.com:jamiebikies/spokehaus.ca.git'

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 10

set :puma_state, "#{shared_path}/tmp/sockets/puma.state"
set :puma_pid, "#{shared_path}/tmp/sockets/puma.pid"

namespace :sidekiq do

  desc 'Sidekiq start'
  task :start do
    on roles(:app) do
      sudo 'start sidekiq'
    end
  end

  desc 'Sidekiq stop'
  task :stop do
    on roles(:app) do
      sudo 'stop sidekiq'
    end
  end

  desc 'Sidekiq restart'
  task :restart do
    on roles(:app) do
      invoke "sidekiq:stop"
      invoke "sidekiq:start"
    end
  end
end

after 'puma:restart', 'sidekiq:restart'


namespace :deploy do

  before 'deploy:assets:precompile', :clear_cache do
    on roles(:app) do
      execute "cd #{release_path} && bower install"
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  # after :stop,       'sidekiq:stop'
  # after :start,      'sidekiq:start'
end
