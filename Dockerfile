ARG DEBIAN_FRONTEND=noninteractive

# Source: https://suragch.medium.com/programming-on-your-phone-a2547f0e293
FROM ubuntu:20.04

MAINTAINER Damien Frigewski <dfrigewski@gmail.com>
LABEL maintainer="dfrigewski@gmail.com"
LABEL Created for execute Flutter projects via Webservice
LABEL version="1.0"
LABEL description="This is a dockerfile for a web based flutter solution \
and also enclosed a VSC IDE for coding."

USER root

RUN apt-get -yq update
RUN mkdir /projects
##############################################################################
############################ FLUTTER INSTALLATION ############################
##############################################################################
# Download and unzip flutter
RUN apt-get install -yq wget
RUN apt-get install -yq xz-utils
RUN wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.22.6-stable.tar.xz
RUN tar xf flutter_linux_1.22.6-stable.tar.xz
RUN rm flutter_linux_1.22.6-stable.tar.xz

# Set env vars for flutter path
ENV PATH="$PATH:$HOME/flutter/bin"

# Install missing tools
RUN apt-get install -yq git && \
    apt-get install -yq curl && \
    apt-get install -yq unzip

# Create new flutter project
RUN cd projects
### /*RUN flutter create ${PROJECT_NAME}*/ ###
RUN git clone https://DamienDrash:"d4M|3n23"@github.com/DamienDrash/Social_Analytix.git
VOLUME /projects
RUN cd /projects && cd Social_Analytix

# Adding web support to the app
RUN flutter channel beta
RUN flutter upgrade
RUN flutter config --enable-web

# Adding web support to the root dir
RUN echo "PWD is: $PWD"
RUN flutter create .

# Building web project
RUN flutter build web


############################################################################
############################ NGINX INSTALLATION ############################
############################################################################
# Installing Nginx
RUN apt-get install -yq nginx

# Enable HTTP connections for Nginx
RUN ufw allow 'Nginx HTTP'

# Create a new site config file
RUN echo "server {\
              listen 80;\
                          root /home/Social_Analytix/build/web;\
                          index index.html index.htm;\
                          location / {\
                              try_files $uri $uri/ =404;\
                          }\
                  }" > /etc/nginx/sites-available/Social_Analytix
# Remove the Nginx default page
RUN rm /etc/nginx/sites-enabled/default

# Adding own app page
RUN ln -s /etc/nginx/sites-available/Social_Analytix /etc/nginx/sites-enabled

# Restart Nginx
RUN systemctl restart nginx

EXPOSE 80