# Change to match your CPU core count
workers 1

# Min and Max threads per worker
threads 1, 6

app_dir = File.expand_path('../..', __FILE__)
shared_dir = File.expand_path('../../shared', app_dir)

# Set up socket location
bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

# Logging
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/tmp/sockets/puma.pid"
state_path "#{shared_dir}/tmp/sockets/puma.state"
activate_control_app

