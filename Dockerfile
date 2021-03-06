# VERSION 1.10.9
# AUTHOR: Maxim Preobrazhensky
# DESCRIPTION: Lightweight Airflow Container
# SOURCE: https://github.com/jjj4x/airflow_with_docker
FROM python:3.7-alpine
LABEL maintainer="max.preobrazhensky@gmail.com"


# **********************************BUILD ARGS**********************************
ARG AIRFLOW_VERSION=1.10.9
ARG AIRFLOW_HOME=/opt/airflow
ARG AIRFLOW__CORE__FERNET_KEY=""
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS="requirements.sample.txt"
ARG LINUX_DEPS="bash"
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
    src/entrypoint.sh \
    src/${PYTHON_DEPS} \
    ${AIRFLOW_HOME}/
# Other files, like dags or tests, can be provided via docker-compose files, etc.

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
    && pip uninstall -y SQLAlchemy && pip install --no-cache-dir SQLAlchemy==1.3.15 \
    && echo "**********************CLEANUP DEPENDENCES**********************" \
    && apk del build-deps \
    && rm -rf /root/.cache/* /tmp/* /var/tmp/* \
    && echo "************************SETUP USERSPACE************************" \
    && addgroup -S airflow \
    && adduser -S -D -H -G airflow -h ${AIRFLOW_HOME} airflow \
    && chown -R airflow:airflow ${AIRFLOW_HOME} \
    && mv ${AIRFLOW_HOME}/entrypoint.sh /

USER airflow

WORKDIR ${AIRFLOW_HOME}

ENTRYPOINT ["/entrypoint.sh"]
# ******************************************************************************
