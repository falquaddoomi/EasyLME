# this Dockerfile expects the build context to be the EasyLME repo root, i.e.
# one folder above ./docker/

FROM --platform=linux/amd64 rocker/shiny-verse:latest AS base

# install renv, which we'll need to restore everything else
RUN R -e 'install.packages("renv")'

# install system deps required for some R packages
RUN apt-get update -qq && apt-get install -y \
  build-essential cmake

WORKDIR /srv/shiny-server/app/

# use renv to restore into this image
COPY ./renv.lock ./renv.lock
COPY ./renv/ ./renv/

# run renv::restore() to install the packages, and use a build-time mount to
# persist the cache, etc.
ENV RENV_PATHS_ROOT=/tmp/renv/global

RUN --mount=type=cache,target=/tmp/renv/ \
  mkdir -p /srv/shiny-server/app/renv/library/ && \
  R -e 'renv::restore(prompt=FALSE); renv::isolate()' && \
  mkdir -p /opt/renv/ && \
  cp -r /tmp/renv/* /opt/renv/

ENV RENV_PATHS_ROOT=/opt/renv/global

# ----

FROM base AS app

COPY ./docker/shiny-config/shiny-server.conf /etc/shiny-server/shiny-server.conf

COPY . .

COPY --from=base /srv/shiny-server/app/renv/library/ /srv/shiny-server/app/renv/library/

EXPOSE 3838
