#!/bin/bash

# run ocis server before doing this

# sudo rm -rf moodle
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
# sudo rm -rf moodle-docker
cp -r moodle-repository_ocis/tests/behat moodle/repository/ocis/tests
git clone https://github.com/moodlehq/moodle-docker.git
cd moodle-docker

WWW_PATH=/home/sabin/www/moodle-ui-test-setup

export MOODLE_DOCKER_WWWROOT=/home/sabin/www/moodle-ui-test-setup/moodle
export MOODLE_DOCKER_DB=pgsql
export MOODLE_DOCKER_PHP_VERSION=8.1
export MOODLE_DOCKER_WEB_HOST=host.docker.internal
export MOODLE_DOCKER_WEB_PORT=8000
export MOODLE_DOCKER_SELENIUM_VNC_PORT=5900
export MOODLE_DOCKER_BROWSER=chrome:94.0

cp ../config.php $MOODLE_DOCKER_WWWROOT/config.php

cat > local.yml <<'EOF'
services:
  webserver:
    extra_hosts:
      - host.docker.internal:host-gateway
    environment:
      MOODLE_DISABLE_CURL_SECURITY: "true" # optional, but useful for testing on localhost or host.docker.internal
      MOODLE_OCIS_URL: "https://host.docker.internal:9200" # optional, used to create OAuth 2 services and repository instance during installation
      MOODLE_OCIS_CLIENT_ID: "xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69"  # optional, used to create OAuth 2 services and repository instance during installation
      MOODLE_OCIS_CLIENT_SECRET: "UBntmLjC2yYCeHwsyj73Uwo9TAaecAetRwMw0xYcvNL9yRdLSUi0hUAHfvCHFeFh" # optional, used to create OAuth 2 services and repository instance during installation
EOF

if [[ "$1" == "down" ]];then
    bin/moodle-docker-compose down -v
    exit 0
fi


mkdir -p traefik/configs traefik/certificates

cat >> traefik/configs/tls.yml <<'EOF'
tls:
stores:
    default:
        defaultCertificate:
            certFile: /certificates/server.crt
            keyFile: /certificates/server.key
EOF

WWW_PATH=/home/sabin/www/moodle-ui-test-setup

# allow container to access docker host via 'host.docker.internal'
cp $MOODLE_DOCKER_WWWROOT/repository/ocis/tests/local.example.yml local.yml


bin/moodle-docker-compose up -d
bin/moodle-docker-compose cp ../../ocis.crt webserver:/usr/local/share/ca-certificates/ 
bin/moodle-docker-compose cp traefik/certificates/server.crt webserver:/usr/local/share/ca-certificates/
bin/moodle-docker-compose exec webserver update-ca-certificates
bin/moodle-docker-compose cp ../../ocis.crt selenium:/usr/local/share/ca-certificates/
bin/moodle-docker-compose cp traefik/certificates/server.crt selenium:/usr/local/share/ca-certificates/
bin/moodle-docker-compose exec selenium update-ca-certificates

bin/moodle-docker-wait-for-db
# Initialize behat environment
bin/moodle-docker-compose exec webserver php admin/tool/behat/cli/init.php

