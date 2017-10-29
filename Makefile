# The default environment file
ENVIRONMENT_FILE=$(shell pwd)/.env

# The default laravel directory
PROJECT_DIRECTORY=$(shell pwd)/laravel

# Available docker containers
CONTAINERS=php-fpm php-cli nginx mysql memcached node

#####################################################
#							 						#
# 							 						#
# RUNTIME TARGETS			 						#
#							 						#
#							 						#
#####################################################

default: run

# Start the containers
run: prerequisite build

# Start individual container
start: prerequisite valid-container
	- docker-compose -f docker-compose.yml up -d --build $(filter-out $@,$(MAKECMDGOALS))

# Stop individual container
stop: prerequisite valid-container
	- docker-compose -f docker-compose.yml stop $(filter-out $@,$(MAKECMDGOALS))

# Halts the docker containers
halt: prerequisite
	- docker-compose -f docker-compose.yml kill

#####################################################
#							 						#
# 							 						#
# SETUP AND BUILD TARGETS			 				#
#							 						#
#							 						#
#####################################################

# Build and prepare the docker containers and the project
build: prerequisite build-containers build-project update-project launch-dependencies

# Build and launch the containers
build-containers:
	- docker-compose -f docker-compose.yml up -d --build

# Build the project
build-project:
# Check whether the project has been initialized
ifeq ("$(wildcard $(PROJECT_DIRECTORY))","")
	- docker-compose -f docker-compose.yml exec php-cli composer --no-scripts create-project laravel/laravel laravel

	# Install using no scripts, run the script after the installation has finished and the env file is in place
	- cp config/laravel/.env laravel/.env

	# Generate the unique application key
	- docker-compose -f docker-compose.yml exec php-cli bash -c "cd laravel && php artisan key:generate"

	# Retrieve the node dependencies
	- docker-compose run node bash -c "cd /usr/src/app && yarn install"
endif

# Update the project and the dependencies
update-project:
	# Update the composer dependencies
	- docker-compose -f docker-compose.yml exec php-cli composer -d=laravel --ansi update

	# Update the yarn dependencies
	- docker-compose run node bash -c "cd /usr/src/app && yarn install"

# Launch application dependencies
launch-dependencies:
	# Launch a queue worker
	- docker-compose -f docker-compose.yml exec php-cli bash -c "cd laravel && nohup sh -c 'php artisan queue:work &' > /dev/null 2>&1"

	# Schedule the cron job
	- docker-compose -f docker-compose.yml exec php-cli bash -c "(crontab -l ; echo \"* * * * * cd /var/www/app/laravel && php artisan schedule:run\") | crontab"

# Remove the docker containers and deletes project dependencies
clean: prerequisite prompt-continue
	# Remove the dependencies
	- rm -rf laravel/vendor

	# Remove the node depenencies
	- rm -rf laravel/node_modules

	# Remove the docker containers
	- docker-compose -f docker-compose.yml down --rmi all -v --remove-orphans

	# Remove all unused volumes
	- docker volume prune -f

	# Remove all unused images
	- docker images prune -a

# Echos the container status
status: prerequisite
	- docker-compose -f docker-compose.yml ps

#####################################################
#							 						#
# 							 						#
# BASH CLI TARGETS			 						#
#							 						#
#							 						#
####################################################

# Opens a bash prompt to the php cli container
bash-cli: prerequisite
	- docker-compose -f docker-compose.yml exec php-cli bash

# Opens a bash prompt to the php fpm container
bash-fpm: prerequisite
	- docker-compose -f docker-compose.yml exec php-fpm bash

# Opens a bash prompt to the php fpm container
bash-mysql: prerequisite
	- docker-compose -f docker-compose.yml exec mysql bash

# Opens a bash prompt to the memcached container
bash-memcached: prerequisite
	- docker-compose -f docker-compose.yml exec memcached bash

# Opens a bash prompt to the nginx container
bash-nginx: prerequisite
	- docker-compose -f docker-compose.yml exec nginx bash

# Opens the mysql cli
mysql-cli:
	- docker-compose -f docker-compose.yml exec mysql mysql -u root -p$(MYSQL_ROOT_PASSWORD)

#####################################################
#							 						#
# 							 						#
# GENERAL TARGETS			 						#
#							 						#
#							 						#
####################################################

# Opens the default browser
open-browser:
	- open http://localhost

#####################################################
#							 						#
# 							 						#
# INTERNAL TARGETS			 						#
#							 						#
#							 						#
####################################################

# Validates the prerequisites such as environment variable
prerequisite: check-environment
include .env
export ENV_FILE = $(ENVIRONMENT_FILE)

# Validates the environment variables
check-environment:
# Check whether the environment file exists
ifeq ("$(wildcard $(ENVIRONMENT_FILE))","")
	- @echo Copying "docker/.env.default";
	- cp docker/.env.default .env
endif
# Check whether the docker binary is available
ifeq (, $(shell which docker-compose))
	$(error "No docker-compose in $(PATH), consider installing docker")
endif

# Validates the containers
valid-container:
ifeq ($(filter $(filter-out $@,$(MAKECMDGOALS)),$(CONTAINERS)),)
	$(error Invalid container provided "$(filter-out $@,$(MAKECMDGOALS))")
endif

# Prompt to continue
prompt-continue:
	@while [ -z "$$CONTINUE" ]; do \
		read -r -p "Would you like to continue? [y]" CONTINUE; \
	done ; \
	if [ ! $$CONTINUE == "y" ]; then \
        echo "Exiting." ; \
        exit 1 ; \
    fi

%:
	@:


# Include node service inorder to build and test javascript