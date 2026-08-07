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
RUN Rscript -e "install.packages(c('shiny','leaflet','terra','sf','dplyr','R6','leafem','bslib','RColorBrewer','shinycssloaders'), repos='https://cloud.r-project.org')"

RUN Rscript -e "library(leaflet); library(terra); library(sf); cat('Packages OK\n')"

# Copy app
COPY . /srv/shiny-server/

# Give the shiny user ownership
RUN chown -R shiny:shiny /srv/shiny-server

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/srv/shiny-server', host='0.0.0.0', port=3838)"]