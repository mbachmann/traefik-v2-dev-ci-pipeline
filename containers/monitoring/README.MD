# Monitoring with Docker, Prometheus, Grafana, Loki, Promtail and cAdvisor

Monitoring for systems and containers comes in a variety of ways.
One of the most used ways is using Prometheus with Node Exporter and cAdvisor
to collect all types of metrics.
And Grafana to make dashboards to show those metrics.

Metrics alone can’t always reveal errors or issues within your systems.
By centralizing your logging, you can send log files to Loki and use Grafana
for visualization and searching,
providing a comprehensive view of your application’s and potential problems.


## Description of the services

**Prometheus:** Prometheus is a toolbox for monitoring and alerting. 
Prometheus is an excellent tool for recording solely numerical time series. 
It is appropriate for both machine-centric monitoring and monitoring of highly dynamic service-oriented architectures. 
Its support for multi-dimensional data collecting and querying is a particular asset in a world of microservices.

**cAdvisor:** cAdvisor (Container Advisor) provides container users with an understanding 
of the resource usage and performance characteristics (metrics) of their running containers. 
It is a running daemon that collects, aggregates, processes, 
and exports information about running containers. Specifically, for each container, 
it keeps resource isolation parameters, historical resource usage, 
histograms of complete historical resource usage, and network statistics. 
This data is exported by container and machine-wide. cAdvisor has native support for Docker containers.

**Node Exporter:** The Node Exporter is an agent that gathers system metrics and exposes them 
in a format which can be ingested by Prometheus. 
The Node Exporter is a project that is maintained through the Prometheus project.

**Promtail:** Promtail is essentially an agent that takes its inspiration from Prometheus. 
Its primary role is to collect logs based on the configuration specified in the scraping settings. 
These logs are then transported to Loki for storage and further analysis.

**Loki:** Loki serves as a specialized data store tailored for log storage. 
It efficiently stores logs, making them easily retrievable for analysis and monitoring purposes. 
Unlike traditional log storage systems, 
Loki’s design is optimized for scalability and performance in handling vast amounts of log data.

**Grafana:** Grafana plays a crucial role in this monitoring stack. 
Once the logs are stored in Loki, Grafana steps in to visualize and present this data on a dashboard. 
Grafana’s user-friendly interface allows for the creation of insightful and customizable dashboards, 
making it easier for users to interpret and analyze the log data in real time.


## Docker Compose file for all services

The docker compose file is located in the monitoring folder. 
It consists of the following services:

- Prometheus
- Grafana
- Loki
- Promtail
- cAdvisor
- Node Exporter

[docker-compose.yml](docker-compose.yml)


The monitoring folder is structured as follows:

```
monitoring
├── docker-compose.yml
├── grafana
│   └── provisioning
│       └── datasources
│           └── datasources.yml
│       └── dashboards
│           └── dashboards.yml
│           └── traefik_rev4.json
│           └── cadvisor_rev6.json
│           └── Spring-boot_rev1.json
│           └── node_rev2.json
├── loki
│   └── loki-config.yml
├── prometheus
│   └── prometheus.yml
│   └── alert.rules.yml
└── promtail
    └── promtail-config.yml
```

Each service except of cAdvisor and node-exporter has its own configuration file.


## Monitoring with Prometheus, cAdvisor, Node-Exporter and Grafana


### Configure Prometheus

Let's breakdown the prometheus.yml:

```yaml
global:
  scrape_interval: 60s
  evaluation_interval: 60s
  scrape_timeout: 10s
  external_labels:
    monitor: 'my-project'

rule_files:
  - 'alert.rules'

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: [ 'localhost:9090' ]
        labels:
          group: 'monitoring'
          application: 'prometheus'

  - job_name: 'traefik'
    metrics_path: '/metrics'
    static_configs:
      - targets: [ 'traefik:8082' ]
        labels:
          group: 'reverse-proxy'
          application: 'traefik'

  - job_name: 'todo-h2-prometheus'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: [ 'todoapp-on-h2:8080' ]
        labels:
          group: 'spring-boot'
          application: 'todo-h2'

  - job_name: 'cadvisor'
    static_configs:
      - targets: [ 'cadvisor:8080' ]
        labels:
          group: 'host'
          application: 'cadvisor'

  - job_name: 'node'
    static_configs:
      - targets: [ 'node-exporter:9100' ]
        labels:
          group: 'container'
          application: 'node-exporter'

```

- **global:** This section contains global configuration options for Prometheus.

- **scrape_interval:** 60s: Specifies the interval at which Prometheus should scrape metrics data. In this case, it's set to 1 minute (1m), meaning Prometheus will scrape metrics from targets every minute.


- **job_name: 'cadvisor'** The job name is set to 'cadvisor', which serves as a label to identify the set of metrics scraped from the cAdvisor service. This helps in organizing and querying the metrics data in Prometheus.

- **static_configs:** This section specifies the targets that Prometheus should scrape for metrics. Static configurations are used when you have a fixed set of targets that don’t change frequently.

- **targets: ['cadvisor:8080']** The target is set to cadvisor:8080, which tells Prometheus to scrape metrics from the cAdvisor container at port 8080. The cadvisor refers to the service name defined in your Docker Compose file, ensuring that Prometheus can locate the correct container within the network.



## Logging with Loki and Promtail

### Loki Configuration

Let's breakdown the loki-config.yml:

```yaml
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  path_prefix: /tmp/loki
  instance_addr: 127.0.0.1
  storage:
    filesystem:
      chunks_directory: /tmp/loki/chunks
      rules_directory: /tmp/loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100

schema_config:
  configs:
    - from: 2020-05-15
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://localhost:9093

analytics:
  reporting_enabled: false

limits_config:
  retention_period: 30d

# compactor:
#   working_directory: /tmp/loki/retention
#  delete_request_store: filesystem
#  retention_enabled: true
#  retention_delete_delay: 2h

```

**Authentication:**

- auth_enabled: false: Authentication is disabled. No need for users to provide credentials.

**Server Configuration:**

- http_listen_port: 3100: Loki server listens for HTTP requests on port 3100.
- grpc_listen_port: 9096: Loki server listens for gRPC requests on port 9096.

**Common Configuration:**

- instance_addr: 127.0.0.1: Loki's instance address is set to localhost (127.0.0.1).
- path_prefix: /tmp/loki: Loki uses /tmp/loki as a path prefix for various operations.
- storage: Specifies Loki's storage configuration.
- filesystem: Loki stores chunks and rules on the local filesystem.
- chunks_directory: /tmp/loki/chunks: Directory for storing chunks.
- rules_directory: /tmp/loki/rules: Directory for storing rules.
- replication_factor: 1: The replication factor is set to 1, meaning there's a single copy of each piece of data.
- ring: Configuration related to distributed storage.
- kvstore: Key-Value store settings.
- store: inmemory: Loki uses an in-memory key-value store.
- Query Range Configuration:

- results_cache: Configures result caching for query ranges.
- cache: Specifies the cache settings.
- embedded_cache: Embedded cache is enabled with a maximum size of 100 MB.


### Promtail Configuration

Let's breakdown the promtail-config.yml:

```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - "localhost"
        labels:
          job: varlogs
          __path__: /var/log/*log

  - job_name: docker
    static_configs:
      - targets:
          - "localhost"
        labels:
          job: docker_logs
          __path__: /var/lib/docker/containers/*/*-json.log
```

**Server Configuration:**

- http_listen_port: 9080: Loki server listens for HTTP requests on port 9080.
- grpc_listen_port: 0: The gRPC server port is set to 0, which means it's dynamically assigned by the system.

**Positions:**

- filename: /tmp/positions.yaml: Specifies the file path where Loki will store the positions of log entries. This information helps Loki keep track of which log entries it has already ingested.

**Clients:**

- Specifies the Loki server URL that Promtail should push logs to.
- url: http://loki:3100/loki/api/v1/push: Promtail sends log entries to Loki using this URL.

**Scrape Configurations:**

- scrape_configs: Describes the jobs or sources that Promtail should scrape logs from.
- job_name: system: Defines a job named "system."
- static_configs: Specifies static configurations for this job.
- targets: - "localhost": Promtail will scrape logs from the local machine ("localhost").
- labels: Provides additional metadata for the scraped logs.
- job: varlogs: Assigns the label "job" with the value "varlogs."
- __path__: /var/log/*log: Defines a target path pattern ("/var/log/*log") where Promtail should look for log files.



Create the network for the monitoring stack

```shell
docker network create monitoring
```


assign the permission with ufw:
```shell
ufw allow from monitoring to 172.17.0.0/16
```
or
```shell
ufw allow from monitoring/16
```






### Install the Docker loki plugin

```shell
install grafana/loki-docker-driver:3.3.2-amd64 --alias loki --grant-all-permissions
```

More information can be found here: https://grafana.com/docs/loki/latest/send-data/docker-driver/


Check the plugin is installed:
```shell
docker plugin ls
```


We need to create a `daemon.json` file in the folder `/etc/docker/` with the following content:

```json
{
  "debug": true,
  "live-restore": false,
  "metrics-addr": "0.0.0.0:9323",
  "experimental": true,
  "log-driver": "loki",
  "log-opts": {
    "loki-url": "http://localhost:3100/loki/api/v1/push",
    "loki-batch-size": "400"
  }
}

```

This tells Docker that it should use the loki log driver instead of the default one and sends the logs to the Loki instance.

```shell
sudo systemctl restart docker
```

You will have to re-create existing containers for them to start sending logs to loki.
Not just restart them. You can use the docker flag `--force-recreate` for this task.


## Logging for Spring Boot

To send logs directly (not through docker logs) from a Spring Boot application to Loki, 
we need to add the following dependencies to the `pom.xml` file:

```xml
<dependency>
    <groupId>com.github.loki4j</groupId>
    <artifactId>loki-logback-appender</artifactId>
    <version>1.6.0</version>
</dependency>
```

Then we need to create the `logback-spring.xml` file in the `src/main/resources` directory. 
Our instance of Loki is available under the http://localhost:3100 address. 
Loki does not index the contents of the logs – but only metadata labels. 
There are some static labels like the app name, log level, or hostname. 
We can set them in the format.label field. 

We will also set some dynamic labels and therefore we enable the Logback markers feature. 
Finally, we are setting the log format pattern. In order to simplify, 
potential transformations with LogQL (Loki query language) we will use JSON notation.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>

  <springProperty name="name" source="spring.application.name" />

  <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
    <encoder>
      <pattern>
        %d{HH:mm:ss.SSS} %-5level %logger{36} %X{X-Request-ID} - %msg%n
      </pattern>
    </encoder>
  </appender>

  <appender name="LOKI" class="com.github.loki4j.logback.Loki4jAppender">
    <!-- (1) -->
    <http>
      <url>http://localhost:3100/loki/api/v1/push</url>
    </http>
    <format>
      <!-- (2) -->
      <label>
        <pattern>app=${name},host=${HOSTNAME},level=%level</pattern>
        <!-- (3) -->
        <readMarkers>true</readMarkers>
      </label>
      <message>
        <!-- (4) -->
        <pattern>
{
   "level":"%level",
   "class":"%logger{36}",
   "thread":"%thread",
   "message": "%message",
   "requestId": "%X{X-Request-ID}"
}
        </pattern>
      </message>
    </format>
  </appender>

  <root level="INFO">
    <appender-ref ref="CONSOLE" />
    <appender-ref ref="LOKI" />
  </root>

</configuration>

```

Besides the static labels, we may send dynamic data, e.g. something specific just for the current request. 
Assuming we have a service that manages persons, we want to log the id of the target person from the request. 


Assuming we have multiple dynamic fields in the single log line, we have to create the LabelMarker object in this way:

```java
LabelMarker marker = LabelMarker.of(() -> Map.of("audit", "true",
                    "X-Request-ID", MDC.get("X-Request-ID"),
                    "X-Correlation-ID", MDC.get("X-Correlation-ID")));
LOG.info(marker, "Person successfully updated");
```
