#! /bin/bash
# Use this code to launch the Migration Script tests from any HDInsight cluster headnode
set -e
set -u
set -x

# Setup SQL tools and environment
sudo curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo sh -c 'curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list'
sudo apt-get -y install unixodbc-dev
sudo apt-get -y update
sudo ACCEPT_EULA=Y apt-get -y install msodbcsql17
sudo ACCEPT_EULA=Y apt-get -y install mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
. ~/.bashrc

# Setup Python 3.6
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get -y update
sudo apt-get -y install python3.6

# Setup PyODBC for Python 3.6
wget https://bootstrap.pypa.io/get-pip.py
sudo python3.6 get-pip.py
sudo apt-get -y install python3.6-dev
sudo apt-get -y update
sudo pip3.6 install pyodbc

# Clone and run the tests
git clone https://github.com/msft-tacox/script-actions.git /tmp/script-actions
cd /tmp/script-actions/HiveMetastoreMigration
chmod +x ./MigrateMetastore.sh
python3.6 MigrateMetastoreTests.py --server $1 --database $2 --username $3 --password $4 --driver 'ODBC Driver 17 for SQL Server' --testSuites All --migrationScriptPath ./MigrateMetastore.sh --cleanup
