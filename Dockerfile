FROM python:3.7-alpine

ARG AIRFLOW_VERSION=1.10.9
ARG AIRFLOW_HOME=/opt/airflow
ARG AIRFLOW__CORE__FERNET_KEY=""
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS="requirements.sample.txt"
ARG LINUX_DEPS="postgresql-dev"
ARG TIMEZONE=UTC

ENV \
    AIRFLOW_HOME=${AIRFLOW_HOME} \
    AIRFLOW__CORE__FERNET_KEY=${AIRFLOW__CORE__FERNET_KEY} \
    TZ=${TIMEZONE}

COPY \
    entrypoint.sh \
    ${PYTHON_DEPS} \
    ${AIRFLOW_HOME}/

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
        libffi-dev \
    && echo "**********************INSTALL DEPENDENCIES**********************" \
    && apk --no-cache add ${LINUX_DEPS} \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r "${AIRFLOW_HOME}/${PYTHON_DEPS}" \
    && pip install --no-cache-dir \
        apache-airflow[crypto,postgres${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    && echo "*******************CLEANUP BUILD DEPENDENCES*******************" \
    && apk del build-deps \
    && echo "TODO cleanup more just in case"
    && echo "****************************ADD USER****************************" \
    && addgroup -S airflow \
    && adduser -S -D -H -G airflow -h ${AIRFLOW_HOME} airflow \
    && chown -R airflow:airflow ${AIRFLOW_HOME} \
    && mv ${AIRFLOW_HOME}/entrypoint.sh /

USER airflow

WORKDIR ${AIRFLOW_HOME}

ENTRYPOINT ["/entrypoint.sh"]
