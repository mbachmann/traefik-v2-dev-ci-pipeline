#!/bin/bash

echo "current script folder: $CUR_SCRIPTDIR"

echo "starting containers"
# ============ REVERSE PROXY =================
cd "${PRJ_ROOT_DIR}/traefik" || exit
./start-traefik.sh

# ============ PORTAINER  =================
cd "${PRJ_ROOT_DIR}/containers/portainer" || exit
./start-portainer.sh

# ============ WORD PRESS  =================
cd "${PRJ_ROOT_DIR}/containers/wordpress" || exit
./start-wordpress.sh

# ==== DB TOOLS ADMINER and PHPMYADMIN  ====
cd "${PRJ_ROOT_DIR}/containers/dbtools" || exit
./start-db-tools.sh

# ========== SPRING BOOT TODOS  =================
cd "${PRJ_ROOT_DIR}/containers/todo" || exit
./start-todo-h2.sh

# ========== SPRING BOOT DEMO-INITIAL  =================
cd "${PRJ_ROOT_DIR}/containers/demo-initial" || exit
./start-demo-initial-h2.sh


cd "${PRJ_ROOT_DIR}" || exit

