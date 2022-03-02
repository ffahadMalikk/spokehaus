server 'spokehaus.ca', user: 'deploy', roles: %w{app db web}

set :branch, 'production'
set :rails_env, 'production'
set :puma_env, 'production'

