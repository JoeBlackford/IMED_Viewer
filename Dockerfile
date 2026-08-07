FROM rocker/r-ver:4.6.1

# Install system libraries
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libabsl-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libudunits2-dev \
    libsqlite3-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /srv/shiny-server

# Copy the project FIRST
COPY . .

# Install renv
RUN Rscript -e "install.packages('renv', repos='https://cloud.r-project.org')"

# Restore packages
RUN Rscript -e "renv::restore(prompt = FALSE)"

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/srv/shiny-server', host='0.0.0.0', port=3838)"]