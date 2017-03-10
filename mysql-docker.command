sudo docker pull mysql:5.7
sudo docker run -d --name=appname -e MYSQL_ROOT_PASSWORD='yourpass' -v /storage/test-mysql/datadir:/var/lib/mysql mysql:5.7
sudo docker ps -a
sudo docker exec -it  dade12eb6093 /bin/bash

