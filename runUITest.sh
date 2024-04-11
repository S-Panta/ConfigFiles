export MOODLE_DOCKER_WWWROOT=/home/sabin/www/moodle-ui-test-setup/moodle
export MOODLE_DOCKER_DB=pgsql
export MOODLE_DOCKER_PHP_VERSION=8.1
export MOODLE_DOCKER_WEB_HOST=host.docker.internal
export MOODLE_DOCKER_WEB_PORT=8000
export MOODLE_DOCKER_SELENIUM_VNC_PORT=5900
export MOODLE_DOCKER_BROWSER=chrome:94.0
WWW_PATH=/home/sabin/www/moodle-ui-test-setup
cp -r $WWW_PATH/moodle-repository_ocis/tests/behat $WWW_PATH/moodle/repository/ocis/tests
$WWW_PATH/moodle-docker/bin/moodle-docker-compose exec webserver php admin/tool/behat/cli/run.php --name="upload a file from share space of ocis to moodle"
