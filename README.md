Testing
------

## Build:
```shell script
docker-compose -f docker-compose.test.yml build
```

## Auto Tests:
```shell script
docker-compose -f docker-compose.test.yml run --rm airflow_tests
docker-compose -f docker-compose.test.yml rm --stop --force postgres
```

## Dev Tests:
```shell script
docker-compose -f docker-compose.test.yml run --rm --name airflow_postgres postgres
docker-compose -f docker-compose.test.yml run --rm --no-deps --name airflow_scheduler airflow_scheduler

```

Why it takes so long to build the image: https://stackoverflow.com/questions/49037742/why-does-it-take-ages-to-install-pandas-on-alpine-linux

Backlog
-------
- [X] Dependencies as ARG:

- [X] Fernet Key as ARG

- [X] The Image should be Generic for DebugExecutor, SequentialExecutor, LocalExecutor

- [X] Investigate Airflow Processes for SequentialExecutor and LocalExecutor (Docker --init)
https://cloud.google.com/solutions/best-practices-for-building-containers#signal-handling
https://github.com/krallin/tini

- [X] Investigate building and image size optimizations

- [X] Provide workflow for Airflow configuration (ENVs and airflow.cfg)

- [X] Provide Timezone support without UTC as default

- [X] Best practices for cache invalidation

- [X] Licence

- [X] Documentation Scaffolding

- [ ] Repository Layout

- [ ] Documentation
    - [ ] The README.md for GitHub
    - [ ] The Description for Docker Hub
    - [ ] Document some insights and nuances

- [ ] Tests
    - [X] The upgrade db is possible.
    - [X] The connections and variables can be created and retrieved
    - [X] A simple DAG with BashOperator is running
    - [X] A DAG with multiple BashOperator is running
    - [X] A simple DAG with PythonOperator is running
    - [X] A DAG with multiple PythonOperator is running
    - [X] A more complex DAG with ETL process and XCom is running
    - [X] Test that UTF8 encoding is working

- [ ] CI/CD
    - [ ] Simple build with tests is passing
    - [ ] Tests are passing
    - [ ] Coverage is collected
    - [ ] More complex build with dependencies and other args is passing
    - [ ] The code is deployed into Docker Hub

- [X] VCS
    - [X] Git Repository
    - [X] Version scheme (Based on Airflow version)
    - [X] AUTHORS

- [X] .editorconfig

- [X] .dockerignore

- [ ] Ship
