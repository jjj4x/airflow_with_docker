# Lightweight Docker Airflow

A simple **Apache Airflow** \[Alpine Linux\] **Docker** image with as little magic as possible.


# Outline

* [License](#license)
* [Notes and Overview](#notes-and-overview)
* [Usage](#usage)
  * [Building and Running](#building-and-running)
  * [Extending](#extending)
  * [Auto Testing](#auto-testing)
  * [Development and Exploration](#development-and-exploration)


# License

This project is licensed under the Apache 2.0 Licence. See [LICENCE](./LICENSE)
for more information.


# Notes and Overview

The image is build mainly for learning purposes and  depends on
[Python Alpine Linux](https://hub.docker.com/_/python).

The versioning scheme is *\<Native Airflow Version\>\[-\<Optional Numeric Suffix\>\]*.
Like, "1.10.9" or "2.0.0-2".

Some notes:
* Timezones are supported.
* UTF-8 is supported out of the box.
* Building will be slow because wheel packages (like pandas and numpy) aren't
  supported on Alpine Linux, so we have to compile them from sources.
  Checkout the discussion for more info: https://stackoverflow.com/questions/49037742/why-does-it-take-ages-to-install-pandas-on-alpine-linux.
* Alpine Linux and musl have an incomplete locale support (https://github.com/gliderlabs/docker-alpine/issues/144#issuecomment-183182278),
  so if your code requires juggling with LC_ALL and similar stuff, the image
  setup will be non-trivial.


# Usage

## Building and Running

To build it without *docker-compose*:
```shell script
docker build -t jjjax/airflow-docker-light -f Dockerfile .
```

It's easier to use the sample compose file:
```shell script
cp docker-compose.{sample,}.yml

docker-compose build

# Will run:
# 1. PostgreSQL.
# 2. Airflow Scheduler which upgrades the db backend.
# 3. Airflow Webserver which will be available under http://localhost:8080.
docker-compose run
```

**Build Arguments Table**:

| Argument                  | Default                     | Comment
| ------------------------- | --------------------------- | -------
| AIRFLOW_VERSION           | 1.10.9                      | The version will be installed at build time
| AIRFLOW_HOME              | /opt/airflow                | If modified, don't forget to sync your docker-compose.yml and other stuff.
| AIRFLOW__CORE__FERNET_KEY | ""                          | If provided, the entrypoint.sh will use the value as is; else, the value from ${AIRFLOW_HOME}/fernet.key will be used.
| AIRFLOW_DEPS              | ""                          | Provided as "mysql,gcp,hdfs"
| PYTHON_DEPS               | src/requirements.sample.txt | The default file is empty; you may put a custom file into src/ and it will be installed with pip
| LINUX_DEPS                | bash                        | Provided as "bash,gcc,make"
| TIMEZONE                  | UTC                         | For example, "Europe/Moscow"


## Extending

There is almost zero magic in the [entrypoint.sh](src/entrypoint.sh), so you may
want to keep it. It has only three actions:
1. If **SLEEP** env is set, it will sleep for a specified amount of seconds.
2. If **AIRFLOW__CORE__FERNET_KEY** env is set, it will be used as is. Else,
   the value from **AIRFLOW_HOME/fernet.key** will be used. That's a reason
   why you should share the **AIRFLOW_HOME** via a volume for multiple airflow
   containers.
3. if **UPGRADE_DB** env is set, the "airflow upgradedb" command will be executed.

The **build argument table** is provided above. Checkout the [Dockerfile](Dockerfile)
to understand their behavior.

The [docker-compose.sample.yml](docker-compose.sample.yml) provides a practical
example. You should note that the **scheduler** and **webserver** have either
share their **AIRFLOW_HOME**, if you want to leverage an auto-generated
**AIRFLOW_HOME/fernet.key**, or you should provide the key via **AIRFLOW__CORE__FERNET_KEY**.


## Auto Testing

Build the test image which differs by **PYTHON_DEPS** (the requirements
will be installed from [requirements.test.txt](src/requirements.test.txt)):
```shell script
docker-compose -f docker-compose.test.yml build
```

Run tests "service" (target) and stop its dependencies after completion:
```shell script
docker-compose -f docker-compose.test.yml run --rm airflow_tests
docker-compose -f docker-compose.test.yml down
```


## Development and Exploration

Build the test image, like in [Auto Testing](#auto-testing):
```shell script
docker-compose -f docker-compose.test.yml build
```

Run the image dependencies:
```shell script
# While the containers are running, we can call our tests from IDE.
docker-compose -f docker-compose.test.yml run --rm --name airflow_scheduler airflow_scheduler
```

After you've finished experimenting, stop the dependencies:
```shell script
docker-compose -f docker-compose.test.yml down
```


# Authors

I've (max.preobrazhensky@gmail.com) made it just for fun: to learn and explore
the **Airflow** hands-on. Thanks to Matthieu "Puckel_" Roisil
(https://github.com/puckel/docker-airflow/tree/master) for a starting point.


# Backlog
- [ ] Decouple from PostgreSQL. It should get by SQLite and SequentialExecutor by default

- [ ] Provide an easier way to turn-off the encryption (AIRFLOW__CORE__FERNET_KEY).

- [ ] CI/CD
    - [ ] Simple build with tests is passing
    - [ ] Tests are passing
    - [ ] Coverage is collected
    - [ ] More complex build with dependencies and other args is passing
    - [ ] The code is deployed into Docker Hub

- [ ] Ship
