# VERSION 1.10.9
# AUTHOR: Maxim Tarasishin
# DESCRIPTION: Lightweight Airflow Container
# SOURCE: https://github.com/jjj4x/airflow_with_docker
FROM python:3.7-alpine
LABEL maintainer="max.preobrazhensky@gmail.com"


# *****************************BUILD ARGS AND NOTES*****************************
# Build without docker-compose:
# docker build -t air -f Dockerfile .

# Build with docker-compose:
#

# For example: docker-compose build --build-arg AIRFLOW_VERSION=1.10.9
ARG AIRFLOW_VERSION=1.10.9

# For example: docker-compose build --build-arg AIRFLOW_HOME=/airflow
ARG AIRFLOW_HOME=/opt/airflow

# For example: docker-compose build --build-arg AIRFLOW__CORE__FERNET_KEY=<your value>
# If provided, the entrypoint.sh will use the value specified at build.
ARG AIRFLOW__CORE__FERNET_KEY=""

# For example: docker-compose build --build-arg AIRFLOW_DEPS=hdfs,kerberos
ARG AIRFLOW_DEPS=""

# For example: docker-compose build --build-arg PYTHON_DEPS=requirements.txt
# The file should be placed in right into the Docker Context.
ARG PYTHON_DEPS="requirements.sample.txt"

# For example: docker-compose build --build-arg LINUX_DEPS="musl-dev gcc"
ARG LINUX_DEPS=""

# For example: docker-compose build --build-arg TIMEZONE="Europe/Moscow"
ARG TIMEZONE=UTC
# ******************************************************************************


# **********************************BUILD BODY**********************************
# The ENVs are relevant for both build and run.
ENV \
    AIRFLOW_HOME=${AIRFLOW_HOME} \
    AIRFLOW__CORE__FERNET_KEY=${AIRFLOW__CORE__FERNET_KEY} \
    TZ=${TIMEZONE}
# Other ENVs relevant for run can be provided via docker-compose files, etc.

# The entrypoint.sh will be moved into / at the end of RUN directive.
COPY \
    entrypoint.sh \
    ${PYTHON_DEPS} \
    ${AIRFLOW_HOME}/
# Other files can be provided via docker-compose files, etc.

RUN \
    echo "**************************SETUP TIMEZONE**************************" \
    && apk --no-cache add tzdata \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    && apk del tzdata \
    && mkdir -p /usr/share/zoneinfo/${TIMEZONE} \
    && rm -r /usr/share/zoneinfo/${TIMEZONE} \
    && cp /etc/localtime /usr/share/zoneinfo/${TIMEZONE} \
    && echo "*******************INSTALL BUILD DEPENDENCIES*******************" \
    && apk --no-cache add --virtual build-deps \
        build-base \
        musl-dev \
        python3-dev \
        postgresql-dev \
        libffi-dev \
    && echo "**********************INSTALL DEPENDENCIES**********************" \
    && apk --no-cache add postgresql-libs ${LINUX_DEPS} \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r "${AIRFLOW_HOME}/${PYTHON_DEPS}" \
    && pip install --no-cache-dir \
        apache-airflow[crypto,postgres${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    && echo "**********************CLEANUP DEPENDENCES**********************" \
    && apk del build-deps \
    && rm -rf /root/.cache/* \
    && echo "************************SETUP USERSPACE************************" \
    && addgroup -S airflow \
    && adduser -S -D -H -G airflow -h ${AIRFLOW_HOME} airflow \
    && chown -R airflow:airflow ${AIRFLOW_HOME} \
    && mv ${AIRFLOW_HOME}/entrypoint.sh /

USER airflow

WORKDIR ${AIRFLOW_HOME}

ENTRYPOINT ["/entrypoint.sh"]
# ******************************************************************************
