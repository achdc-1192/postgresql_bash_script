#!/bin/bash

#script for installing postgresql from source

check_status() {
	status=$1

	if [ status -ne 0 ];then
		echo "**********Failed*************"
		exit 1
	else
		echo "***********Success************"
	fi
}

echo "Checking environment variables required "

sudo apt-get install make gcc zlib1g-dev libreadline6-dev bison flex git

check_status $?

echo "**********Creating user and group postgres*********"

sudo groupadd postgres
sudo useradd -g postgres postgres
echo "********Creating directory for pgsql and data*******"

sudo mkdir -p /usr/local/pgsql
sudo mkdir -p /usr/local/postgres
sudo mkdir -p /usr/local/postgres/data

echo "*********Changing owner permissions*****************"

sudo chown -R postgres:postgres /usr/local/pgsql
sudo chown -R postgres:postgres /usr/local/postgres
sudo chown -R postgres:postgres /usr/local/postgres/data

echo "*********Downloading postgresql source*************"

git clone git://git.postgresql.org/git/postgresql.git


echo "********Changing directory to postgresql***********"

cd postgresql


echo "*****Running configure script***********************"

sudo ./configure --prefix=/usr/local/pgsql
check_status $?


echo "*********Running make and make install************"

sudo make

check_status $?

sudo make install

check_status $?

#uncomment the following line if you are installing the same in data folder
#sudo rm -r /usr/local/postgres/data/

echo "**********instantiating and running db as postgres user**************"

sudo su postgres << 'EOF'
/usr/local/pgsql/bin/initdb --encoding=utf8 -D /usr/local/postgres/data
/usr/local/pgsql/bin/pg_ctl -D /usr/local/postgres/data -l /usr/local/postgres/data/server.log start
echo "sleeping for 10 sec for server to start"
sleep 10
/usr/local/pgsql/bin/psql -f /home/anurag/scripts/hello.sql
/usr/local/pgsql/bin/psql -c 'select * from hello;' -U globus hello_postgres;
EOF


#the following lines are the commands we can add for production use

#echo "adding to startup scripts"

#sudo cp ./contrib/start-scripts/linux /etc/init.d/postgresql
#sudo chmod +x /etc/init.d/postgresql



#echo "starting the postgresql service"

#sudo service postgresql start



