FROM centos:7

ENV ES_PKG_NAME elasticsearch-7.17.1

RUN groupadd -g 1000 elasticsearch && useradd elasticsearch -u 1000 -g 1000

RUN yum makecache && \
    yum -y install wget \
    yum -y install perl-Digest-SHA \
    yum -y install java-1.8.0-openjdk.x86_64


# Install Elasticsearch.
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.1-linux-x86_64.tar.gz && \
  wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.1-linux-x86_64.tar.gz.sha512 && \
  shasum -a 512 -c elasticsearch-7.17.1-linux-x86_64.tar.gz.sha512 && \
  tar -xzf elasticsearch-7.17.1-linux-x86_64.tar.gz && \

  rm -f elasticsearch-7.17.1-linux-x86_64.tar.gz && \
  mv /$ES_PKG_NAME /elasticsearch

# Define mountable directories.
# VOLUME ["/data"]

# Mount elasticsearch.yml config
# ADD config/elasticsearch.yml /elasticsearch/config/elasticsearch.yml

# Define working directory.
# WORKDIR /data
RUN mkdir /var/lib/logs /var/lib/data

COPY elasticsearch.yml /elasticsearch/config

RUN chmod -R 777 /elasticsearch && \
    chmod -R 777 /var/lib/logs && \
    chmod -R 777 /var/lib/data

USER elasticsearch
# Define default command.
CMD ["/elasticsearch/bin/elasticsearch"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200
EXPOSE 9300
