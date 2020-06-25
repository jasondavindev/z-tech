#!/bin/bash
RESTORE='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\e[0;33m'

export PROJECT_NAME=z_tech
export PROJECT_BASE=$(pwd)

function dkupd {
  CD=$(pwd)
  cd $PROJECT_BASE
  docker-compose up -d
  exitcode=$?
  cd $CD
  return $exitcode
}

function dkupa {
  CD=$(pwd)
  cd $PROJECT_BASE
  docker-compose up
  exitcode=$?
  cd $CD
  return $exitcode
}

function dkdown {
  CD=$(pwd)
  cd $PROJECT_BASE
  docker-compose down
  exitcode=$?
  cd $CD
  return $exitcode
}

function dk {
  docker-compose run --rm "app" $@
}

function pkg_install {
  CD=$(pwd)
  cd $PROJECT_BASE
  docker-compose run --rm app "yarn"
  cd $CD
}

function dktest {
  dk yarn test
  exitcode=$?
  return $exitcode
}

function db_setup {
  docker-compose up -d db
  docker exec -ti z-tech-db psql -U postgres -c "create database z_tech_development"
  docker exec -ti z-tech-db psql -U postgres -c "create database z_tech_test"
  docker-compose run --rm "app" yarn run run:migrations:dev
  docker-compose run --rm "app" yarn run run:migrations:test
  docker-compose down
}

function setup_dev_environment {
  docker volume create --name development_postgres
  docker network create development_network
  cp .env.example .env
  pkg_install
  db_setup
}

function devhelp {
  echo -e "${GREEN}devhelp${RESTORE}                Prints ${RED}devhelp${RESTORE}"
  echo -e ""
  echo -e "${GREEN}setup_dev_environment${RESTORE}  ${RED}Setup dev environment (node packages, database and migrations)${RESTORE}"
  echo -e ""
  echo -e "${GREEN}db_setup${RESTORE}               ${RED}Setup database${RESTORE}"
  echo -e ""
  echo -e "${GREEN}pkg_install${RESTORE}            ${RED}Install node packages${RESTORE}"
  echo -e ""
  echo -e "${GREEN}dkupa${RESTORE}                  ${RED}Starts docker services${RESTORE} in attach mode"
  echo -e ""
  echo -e "${GREEN}dkupd${RESTORE}                  ${RED}Starts docker services${RESTORE} in detached mode"
  echo -e ""
  echo -e "${GREEN}dk \"cmd\"${RESTORE}               ${RED}Runs the 'cmd' command inside the container"
  echo -e ""
  echo -e "${GREEN}dkdown${RESTORE}                 ${RED}Stop and remove docker containers${RESTORE}"
  echo -e ""
  echo -e "${GREEN}dktest${RESTORE}                 ${RED}Run all tests${RESTORE}"
  echo -e ""
}

devhelp
