# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
cpu_cores = `sm-cpuinfo -p | grep cpu_alloc | cut -d':' -f2`
worker_processes [(cpu_cores.to_i * 1.9).to_i, 12].max

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
home = '/home/quikchat'
working_directory "#{home}/app/current" # available in 0.94.0+

# nuke workers after 15 seconds instead of 60 seconds (the default)
timeout 15

pid "#{home}/app/shared/pids/unicorn.pid"

stderr_path "#{home}/app/shared/log/unicorn.stderr.log"
stdout_path "#{home}/app/shared/log/unicorn.stdout.log"

# combine Ruby 2.0.0dev or REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

GC::Profiler.enable

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  srand(Time.now.to_i * Process.pid)
end
