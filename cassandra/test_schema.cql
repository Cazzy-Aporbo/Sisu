version: "3.9"

services:
  cassandra:
    image: cassandra:4.1
    container_name: cassandra
    ports:
      - "9042:9042"
    environment:
      CASSANDRA_CLUSTER_NAME: "ChatDemoCluster"
      CASSANDRA_DC: "dc1"
      CASSANDRA_RACK: "rack1"
      CASSANDRA_START_RPC: "true"
    healthcheck:
      test: ["CMD-SHELL", "cqlsh -e 'DESCRIBE KEYSPACES'"]
      interval: 20s
      timeout: 10s
      retries: 10
    volumes:
      - cassandra_data:/var/lib/cassandra

volumes:
  cassandra_data: