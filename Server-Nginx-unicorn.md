# Install-Nginx

Ubuntu 10.04:

  $ deb http://nginx.org/packages/ubuntu/ lucid nginx
  
  $ deb-src http://nginx.org/packages/ubuntu/ lucid nginx

Debian 6:

  $ deb http://nginx.org/packages/debian/ squeeze nginx 
  
  $ deb-src http://nginx.org/packages/debian/ squeeze nginx 

 Ubuntu PPA

This PPA is maintained by volunteers and is not distributed by nginx.org. It has some additional compiled-in modules and may be more fitting for your environment.

You can get the latest stable version of Nginx from the Nginx PPA on Launchpad: You will need to have root privileges to perform the following commands.

For Ubuntu 10.04 and newer:

 $ sudo -s
 
 $ nginx=stable # use nginx=development for latest development version
 
 $ add-apt-repository ppa:nginx/$nginx
 
 $ apt-get update 
 
 $ apt-get install nginx

If you get an error about add-apt-repository not existing, you will want to install python-software-properties. For other Debian/Ubuntu based distributions, you can try the lucid variant of the PPA which is the most likely to work on older package sets.

$ sudo -s

$ nginx=stable # use nginx=development for latest development version

$ echo "deb http://ppa.launchpad.net/nginx/$nginx/ubuntu lucid main" > /etc/apt/sources.list.d/nginx-$nginx-lucid.list
$ apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C

$ apt-get update 

$ apt-get install nginx




# Config Unicorn
 open foder your_app/config 
 add new file unicorn.rb
 ```ruby
    rails_env = ENV['RAILS_ENV'] || 'production'
    worker_processes 4
    working_directory "/your_rails_app" 
    listen "/tmp/nginx.sock", :backlog => 64
    listen 8088, :tcp_nopush => true
    timeout 30
    pid "/path_your_rails_app/config/shared/pids/unicorn.pid" 
    stderr_path "/var/log/unicorn/unicorn.stderr.log" 
    stderr_path "/var/log/unicorn/unicorn.stdout.log" 
    preload_app true
    GC.respond_to?(:copy_on_write_friendly=) and
      GC.copy_on_write_friendly = true
    check_client_connection false
 
    before_fork do |server, worker|
      defined?(ActiveRecord::Base) and
        ActiveRecord::Base.connection.disconnect!
    end
     
    after_fork do |server, worker|
      # the following is *required* for Rails + "preload_app true",
      defined?(ActiveRecord::Base) and
        ActiveRecord::Base.establish_connection
    end
 ```
 # Create startup script for unicorn: vim /etc/init.d/unicornyourrails_app
 ```
  set -u
  set -e
   
  APP_NAME=project_name
  APP_ROOT="/path_your_rails_app/$APP_NAME" 
  CNF="$APP_ROOT/config/unicorn.rb" 
  PID="$APP_ROOT/config/shared/pids/unicorn.pid" 
  ENV=production
   
  UNICORN_OPTS="-D -E $ENV -c $CNF" 
   
  old_pid="$PID.oldbin" 
   
  cd $APP_ROOT || exit 1
   
  sig () {
          test -s "$PID" && kill -$1 `cat $PID`
  }
   
  oldsig () {
          test -s $old_pid && kill -$1 `cat $old_pid`
  }
  
case ${1-help} in
start)
        sig 0 && echo >&2 "Already running" && exit 0
        cd $APP_ROOT ; unicorn_rails $UNICORN_OPTS
        ;;
stop)
        sig QUIT && exit 0
        echo >&2 "Not running" 
        ;;
force-stop)
        sig TERM && exit 0
        echo >&2 "Not running" 
        ;;
restart|reload)
        sig HUP && echo reloaded OK && exit 0
        echo >&2 "Couldn't reload, starting instead" 
        unicorn_rails $UNICORN_OPTS
        ;;
upgrade)
        sig USR2 && exit 0
        echo >&2 "Couldn't upgrade, starting instead" 
        unicorn_rails $UNICORN_OPTS
        ;;
rotate)
        sig USR1 && echo rotated logs OK && exit 0
        echo >&2 "Couldn't rotate logs" && exit 1
        ;;
*)
        echo >&2 "Usage: $0 <start|stop|restart|upgrade|rotate|force-stop>" 
        exit 1
        ;;
esac
</start|stop|restart|upgrade|rotate|force-stop>
 ```
 #Start/Stop Unicorn
 ```
 /etc/init.d/unicorn_rails_recruit_app stop
 /etc/init.d/unicorn_rails_recruit_app start
 bundle exec unicorn -E production -c /web/ventura/online_test/config/unicorn.rb -D
 ```
 
