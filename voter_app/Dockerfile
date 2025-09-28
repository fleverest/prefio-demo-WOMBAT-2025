# Created using Claude Sonnet 4:
# https://claude.ai/share/04f7be83-a18a-4c8a-a4a9-25be43da27b1

FROM docker.io/rocker/shiny:4.3.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('shiny', 'sortable', 'digest', 'tibble', 'readr'), repos='https://cran.rstudio.com/')"

# Install Cloudflare tunnel (cloudflared)
RUN wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && dpkg -i cloudflared-linux-amd64.deb \
    && rm cloudflared-linux-amd64.deb

# Create data directory
RUN mkdir -p /data

# Create app directory
RUN mkdir -p /srv/app

WORKDIR /srv/app

# Copy the server files
COPY app.R ./
COPY entrypoint.sh ./

# Make scripts executable
RUN chmod +x entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]
