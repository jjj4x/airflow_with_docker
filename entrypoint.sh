#!/bin/sh

# The ability to wait for some other services.
if [ -n "${SLEEP}" ] && [ "${SLEEP}" -gt 0 ]; then
  echo "Sleeping for ${SLEEP} seconds."
  sleep "${SLEEP}"
fi

# 1. If AIRFLOW__CORE__FERNET_KEY was set manually -> use it.
# 2. If ${AIRFLOW_HOME}/fernet.key file is present -> use it.
# 3. Else, create ${AIRFLOW_HOME}/fernet.key and.. -> use it.
if [ -z "${AIRFLOW__CORE__FERNET_KEY}" ]; then
  fernet_key_file="${AIRFLOW_HOME}/fernet.key"

  if [ ! -f "${fernet_key_file}" ]; then
    python > "${fernet_key_file}" \
      -c 'from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())'
    echo "Created '${fernet_key_file}'."
  fi

  AIRFLOW__CORE__FERNET_KEY=$(cat "${fernet_key_file}")
  echo "Using Fernet Key from '${fernet_key_file}'."
fi

# The ability to "airflow upgradedb" before calling other commands.
if [ "${UPGRADE_DB}x" != "x" ]; then
  airflow upgradedb
fi

exec "$@"
