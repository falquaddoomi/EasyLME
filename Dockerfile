FROM --platform=linux/amd64 rocker/shiny-verse:latest

# install renv, which we'll need to restore everything else
RUN R -e 'install.packages("renv")'

# install system deps required for some R packages
RUN apt-get update -qq && apt-get install -y \
  build-essential cmake

WORKDIR /srv/shiny-server/app/

# use renv to restore into this image
COPY ./renv.lock /srv/shiny-server/app/renv.lock
COPY ./renv /srv/shiny-server/app/renv

# run renv::restore() to install the packages, and use a build-time volume to store changes
RUN --mount=type=cache,target=/root/.cache \
    R -e 'renv::restore()'

COPY ./shiny-config/shiny-server.conf /etc/shiny-server/shiny-server.conf

COPY . /srv/shiny-server/app

EXPOSE 3838
