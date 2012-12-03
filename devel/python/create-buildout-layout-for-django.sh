#/usr/bin/bash
PROJECT_NAME=$1
if [ $# -lt 1 ]; then
	echo " !! No project name given !!"
	echo "Usage: $0 project_name"
	exit 1
fi
echo "Creating buildout project layout for ${PROJECT_NAME} ....."

# create the project directory
mkdir ${PROJECT_NAME}
if [ $? -ne 0 ]; then exit 1; fi

# go to project directory
cd ${PROJECT_NAME}
if [ $? -ne 0 ]; then exit 1; fi

# create necessary files and directories in the project directory
touch	LICENSE

echo "; for more info: http://jacobian.org/writing/django-apps-with-buildout/" > README

wget http://svn.zope.org/*checkout*/zc.buildout/trunk/bootstrap/bootstrap.py

touch buildout.cfg

echo "[buildout]
parts = ${PROJECT_NAME}
"> buildout.cfg

touch setup.py

mkdir -p src/${PROJECT_NAME}

touch src/${PROJECT_NAME}/__init__.py

