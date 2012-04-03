# -*- coding: utf-8 -*-
pid_file    = '/u/apps/shelr/shared/pids/unicorn.pid'
socket_file = '/u/apps/shelr/shared/pids/unicorn.sock'

pid              pid_file
timeout          20
preload_app      true
worker_processes 8

listen socket_file, backlog: 1024

before_fork do |server, worker|
  # Перед тем, как создать первый рабочий процесс, мастер отсоединяется от базы.
  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.connection.disconnect!

  #kill old master instance
  old_pid = '/u/apps/shelr/shared/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.establish_connection
end
