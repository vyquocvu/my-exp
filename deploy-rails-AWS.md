## How to deploy a rails app on Amazon Web Service.
  
###I. Environment

  1. AWS EC2, Ubuntu 16.04
  2. Gem 2.5.1
  3. RVM 2.3.0@rails500
  4. Nginx: nginx/1.10.0
  
###II. Config
####  1. Unicorn
  * Install
  
    Add to Gemfile
     ```
      gem 'unicorn'
     ```
     Save, exit and bundle
     ```
      $ bundle
     ```
  * Configure Unicorn
  
    In file config/unicorn.rb
    ```
      $ vi config/unicorn.rb
    ```
    Add this code below
    ```
      # set path to application
      app_dir = File.expand_path("../..", __FILE__)
      shared_dir = "#{app_dir}/shared"
      working_directory app_dir


      # Set unicorn options
      worker_processes 2
      preload_app true
      timeout 30

      # Set up socket location
      listen "#{shared_dir}/sockets/unicorn.sock", :backlog => 64

      # Logging
      stderr_path "#{shared_dir}/log/unicorn.stderr.log"
      stdout_path "#{shared_dir}/log/unicorn.stdout.log"

      # Set master PID location
      pid "#{shared_dir}/pids/unicorn.pid"
    ```
    Now create the directories, the configuration file need them.
    ```
      $ mkdir -p shared/pids shared/sockets shared/log
    ```
    
  * Create Unicorn Init Script
    
    Create a script (replace appname)
    ```
      $ sudo vi /etc/init.d/unicorn_appname
    ```
    Copy and paste the following code block into it (USER and APP_NAME need to change)
    ```
      #!/bin/sh

      ### BEGIN INIT INFO
      # Provides:          unicorn
      # Required-Start:    $all
      # Required-Stop:     $all
      # Default-Start:     2 3 4 5
      # Default-Stop:      0 1 6
      # Short-Description: starts the unicorn app server
      # Description:       starts unicorn using start-stop-daemon
      ### END INIT INFO

      set -e

      USAGE="Usage: $0 <start|stop|restart|upgrade|rotate|force-stop>"

      # app settings
      USER="deploy"
      APP_NAME="appname"
      APP_ROOT="/home/$USER/$APP_NAME"
      ENV="production"

      # environment settings
      PATH="/home/$USER/.rbenv/shims:/home/$USER/.rbenv/bin:$PATH"
      CMD="cd $APP_ROOT && bundle exec unicorn -c config/unicorn.rb -E $ENV -D"
      PID="$APP_ROOT/shared/pids/unicorn.pid"
      OLD_PID="$PID.oldbin"

      # make sure the app exists
      cd $APP_ROOT || exit 1

      sig () {
        test -s "$PID" && kill -$1 `cat $PID`
      }

      oldsig () {
        test -s $OLD_PID && kill -$1 `cat $OLD_PID`
      }

      case $1 in
        start)
          sig 0 && echo >&2 "Already running" && exit 0
          echo "Starting $APP_NAME"
          su - $USER -c "$CMD"
          ;;
        stop)
          echo "Stopping $APP_NAME"
          sig QUIT && exit 0
          echo >&2 "Not running"
          ;;
        force-stop)
          echo "Force stopping $APP_NAME"
          sig TERM && exit 0
          echo >&2 "Not running"
          ;;
        restart|reload|upgrade)
          sig USR2 && echo "reloaded $APP_NAME" && exit 0
          echo >&2 "Couldn't reload, starting '$CMD' instead"
          $CMD
          ;;
        rotate)
          sig USR1 && echo rotated logs OK && exit 0
          echo >&2 "Couldn't rotate logs" && exit 1
          ;;
        *)
          echo >&2 $USAGE
          exit 1
          ;;
      esac
    ```
    Update the script's permissions and enable Unicorn to start on boot:
    ```
      $ sudo chmod 755 /etc/init.d/unicorn_appname
      $ sudo update-rc.d unicorn_appname defaults
      $ sudo service unicorn_appname start
    ```

####  2. Nginx

  * Install and Configure Nginx
    ```
      $ sudo apt-get install nginx
    ```
    Now open the default server block
    ```
      $ sudo vi /etc/nginx/sites-available/default
    ```
    Replace the contents
    ```
      upstream app {
          # Path to Unicorn SOCK file, as defined previously
          server unix:/home/username/appname/shared/sockets/unicorn.sock fail_timeout=0;
      }

      server {
          listen 80;
          server_name your_DNS_name;

          root /home/username/appname/public;

          try_files $uri/index.html $uri @app;

          location ~ ^/assets/ {
              root /home/username/appname/public;
              gzip_static on;
              expires max;
              add_header Cache-Control public;
          }

          location @app {
              proxy_pass http://app;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header Host $http_host;
              proxy_redirect off;
          }

          error_page 500 502 503 504 /500.html;
          client_max_body_size 4G;
          keepalive_timeout 10;
      }
    ```
    Remember:
    
      `your_DNS_name` is domain name
      
      `username` is ubuntu user
      
      `appname` is directory's name of rails app
      
      Or

      `home/username/appname` is path to your app folder

    Restart Nginx (orther stop, start, restart)
    ```
      $ sudo service nginx restart
    ```
    Finaly, check http://server_public_IP/

####  3. Fix bug
  But "Something Went Wrong"
  
  1. Set up server, security group. [Video](https://www.youtube.com/watch?v=RBPr4VcerfM)
  
  2. Missing secret_key_base for 'production' environment, set this value in config/secrets.yml
  
    `RAILS_ENV=production rake secret`
    
    `vi /etc/profile`
    
    append 
    
    `export SECRET_KEY_BASE=GENERATED_CODE`
    
    restart Unicorn
    
    `sudo service unicorn_appname start`
    
    reload Nginx
    
    `sudo service nginx start`
  
  3. Rails assets not load
    
    I was able to solve this problem by changing: `config.assets.compile = false` to `config.assets.compile = true` in `/config/environments/production.rb`
    
    RAILS_ENV=production bundle exec rake assets:precompile
  
  4. Make a shell script to restart app.
    
    Everytime i need to change somethings, i must run a lot of commands again. So, I made a \*.sh file to just run it one times.
    ```
      RAILS_ENV=production rake secret
      RAILS_ENV=production bundle exec rake assets:precompile
      sudo service unicorn_symmap stop
      sudo service unicorn_symmap start
      sudo service nginx restart
    ```
    
###Goodluck!
    
    
