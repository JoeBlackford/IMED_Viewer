FROM rocker/shiny:4.6.1

# Install system libraries required by sf and terra
RUN apt-get update && apt-get install -y \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libudunits2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c( \
    'shiny', \
    'leaflet', \
    'terra', \
    'sf', \
    'dplyr', \
    'R6', \
    'leafem', \
    'bslib', \
    'RColorBrewer', \
    'shinycssloaders' \
), repos='https://cloud.r-project.org')"

# Copy app
COPY . /srv/shiny-server/

# Give the shiny user ownership
RUN chown -R shiny:shiny /srv/shiny-server

EXPOSE 3838

CMD ["/usr/bin/shiny-server"]