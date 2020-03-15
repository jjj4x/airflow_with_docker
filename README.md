Header
######

Why it takes so long to build the image: https://stackoverflow.com/questions/49037742/why-does-it-take-ages-to-install-pandas-on-alpine-linux

Backlog
#######
- [X] Dependencies as ARG:

- [X] Fernet Key as ARG

- [X] The Image should be Generic for DebugExecutor, SequentialExecutor, LocalExecutor

- [ ] Investigate Airflow Processes for SequentialExecutor and LocalExecutor (Docker --init)
https://cloud.google.com/solutions/best-practices-for-building-containers#signal-handling
https://github.com/krallin/tini

- [X] Investigate building and image size optimizations

- [ ] Provide workflow for Airflow configuration (ENVs and airflow.cfg)

- [X] Provide Timezone support without UTC as default

- [ ] Investigate encodings

- [X] Best practices for cache invalidation

- [X] Licence

- [X] Documentation Scaffolding

- [ ] Documentation

- [ ] CI/CD

- [ ] Tests

- [X] VCS

- [ ] .editorconfig

- [ ] .dockerignore
