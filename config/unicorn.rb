# coding: utf-8
#
# unicorn_rails -c ./config/unicorn.rb -E staging -D

rails_env = ENV['RAILS_ENV'] || 'production'
# NOTE please change
def decide_worker_processes(env)
  case env
  when "production", "admin"
    12
  when "inhouse"
    1
  else
    4
  end
end

worker_processes decide_worker_processes(rails_env)

address = "127.0.0.1"
listenport = 3010
listen "/tmp/unicorn_#{listenport}.sock"
listen "#{address}:#{listenport}", :tcp_nopush => true

pid File.expand_path("tmp/pids/unicorn_#{listenport}.pid", ENV['RAILS_ROOT'])

stdout_path File.expand_path("log/unicorn_#{listenport}.stdout.log", ENV['RAILS_ROOT'])
stderr_path File.expand_path("log/unicorn_#{listenport}.stderr.log", ENV['RAILS_ROOT'])

preload_app true
timeout 30

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{ server.config[:pid] }.oldbin"
  unless old_pid == server.pid
    begin
      Process.kill :QUIT, File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end

