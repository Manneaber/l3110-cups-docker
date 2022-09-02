FROM ubuntu:latest

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM" 

RUN sed -i 's|http://archive.ubuntu.com|http://th.archive.ubuntu.com|g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
  sudo \
  locales \
  whois \
  cups \
  cups-client \
  cups-bsd \
  lsb \
	avahi-daemon \
	cups-pdf \
	cups-filters \
  ghostscript \
  foomatic-db-compressed-ppds

ENV LANG=en_US.UTF-8 \
  LC_ALL=en_US.UTF-8 \
  LANGUAGE=en_US:en

RUN useradd \
  --groups=sudo,lp,lpadmin \
  --create-home \
  --home-dir=/home/print \
  --shell=/bin/bash \
  --password=$(mkpasswd print) \
  print \
  && sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /var/lib/apt/lists/partial

WORKDIR $HOME/setup
COPY ./epson-inkjet-printer-escpr_1.7.21-1lsb3.2_amd64.deb ./ 
RUN dpkg -i ./epson-inkjet-printer-escpr_1.7.21-1lsb3.2_amd64.deb
RUN rm ./epson-inkjet-printer-escpr_1.7.21-1lsb3.2_amd64.deb

# Default shell
CMD ["/usr/sbin/cupsd", "-f"]
