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


**Explanation of `daemon.json`**

This `daemon.json` file configures the behavior of the Docker daemon. Below is a breakdown of each setting:

**Debug Mode**
```json
"debug": true
```
- Enables debug mode, providing more detailed logs for troubleshooting.
- Useful for diagnosing issues but should be disabled in production to enhance security and performance.

**Live Restore**
```json
"live-restore": false
```
- Determines whether containers should keep running if the Docker daemon crashes or is restarted.
- `false`: Containers will stop when the daemon stops.
- `true`: Containers continue running even if the daemon is restarted.

**Metrics Address**
```json
"metrics-addr": "0.0.0.0:9323"
```
- Exposes Docker daemon metrics on all network interfaces (`0.0.0.0`) at port `9323`.
- Useful for monitoring Docker with tools like Prometheus.

**Experimental Features**
```json
"experimental": true
```
- Enables Docker experimental features.
- Some features may be unstable or subject to change in future releases.

**Log Driver Configuration**
```json
"log-driver": "loki"
```
- Specifies **Loki** as the log driver for Docker container logging.
- Loki is a log aggregation system optimized for efficient storage and querying of logs.

**Log Options**
```json
"log-opts": {
  "loki-url": "http://localhost:3100/loki/api/v1/push",
  "loki-batch-size": "400"
}
```
- **`"loki-url"`**: Defines the Loki service endpoint for pushing logs.
    - Here, it points to a locally running Loki instance on port `3100`.
- **`"loki-batch-size"`**: Defines the number of log messages sent in a single batch.
    - Larger batches improve efficiency but may increase memory usage.

**Summary**
This configuration:
- Enables debugging.
- Disables live restore.
- Exposes daemon metrics on port `9323`.
- Enables experimental features.
- Configures Docker to use **Loki** for logging with batch settings.


After creating the `daemon.json` file, restart the Docker service to apply the changes:

```shell
sudo systemctl restart docker
```

You will have to re-create existing containers for them to start sending logs to loki.
Not just restart them. You can use the docker flag `--force-recreate` for this task.

## Configure Grafana

Grafana is a powerful tool for creating visualizations and dashboards. 

We can configure Grafana to use Loki as a data source and create dashboards to visualize log data. 
We need to create a `grafana` directory in the `monitoring` directory and create the `provisioning` directory inside it.
Then we need to create the `datasources` and `dashboards` directories inside the `provisioning` directory.

### Grafana Datasources

To configure Grafana, we need to create a `datasources.yml` file in the `provisioning/datasources` directory.

```yaml
# config file version
apiVersion: 1

# list of datasources that should be deleted from the database
deleteDatasources:
  - name: Prometheus
    orgId: 1

# list of datasources to insert/update depending
# whats available in the database
datasources:
  # <string, required> name of the datasource. Required
- name: Prometheus
  # <string, required> datasource type. Required
  type: prometheus
  # <string, required> access mode. direct or proxy. Required
  access: browser
  # <int> org id. will default to orgId 1 if not specified
  orgId: 1
  # <string> url
  url: http://prometheus:9090
  # <string> database password, if used
  password:
  # <string> database user, if used
  user:
  # <string> database name, if used
  database:
  # <bool> enable/disable basic auth
  basicAuth: false
  # <string> basic auth username
  basicAuthUser: admin
  # <string> basic auth password
  basicAuthPassword: foobar
  # <bool> enable/disable with credentials headers
  withCredentials:
  # <bool> mark as default datasource. Max one per org
  isDefault: true
  # <map> fields that will be converted to json and stored in json_data
  jsonData:
     graphiteVersion: "1.1"
     tlsAuth: false
     tlsAuthWithCACert: false
  # <string> json object of data that will be encrypted.
  secureJsonData:
    tlsCACert: "..."
    tlsClientCert: "..."
    tlsClientKey: "..."
  version: 1
  # <bool> allow users to edit datasources from the UI.
  editable: true

```


**Grafana Configuration Explanation**

**Overview**
This configuration file is used to manage data sources in Grafana. It specifies the version of the configuration file, defines data sources that should be deleted, and provides details for adding or updating data sources.

**Configuration Sections**

**1. API Version**
The `apiVersion: 1` defines the version of the configuration format.

**2. Deleting Data Sources**
The `deleteDatasources` section lists data sources that should be removed from Grafana. In this case, the data source named `Prometheus` with `orgId: 1` is marked for deletion.

**3. Adding or Updating Data Sources**
The `datasources` section defines the data sources that should be added or updated. Each data source entry contains multiple configuration parameters:

- **Name**: The name of the data source (`Prometheus`).
- **Type**: The type of data source (`prometheus`).
- **Access Mode**: Defines how the data source is accessed (`browser` mode means direct access from the user's browser).
- **Organization ID**: The organization ID to which the data source belongs (`orgId: 1`).
- **URL**: The connection URL of the data source (`http://prometheus:9090`).
- **Authentication**:
    - Basic authentication is disabled (`basicAuth: false`).
    - However, basic authentication credentials are specified (`basicAuthUser: admin`, `basicAuthPassword: foobar`).
- **With Credentials**: Determines if credentials should be included in requests (`withCredentials` is unspecified).
- **Default Data Source**: This data source is marked as the default (`isDefault: true`).
- **JSON Data**: Includes additional configuration settings:
    - `graphiteVersion`: Specifies the Graphite version (`1.1`).
    - `tlsAuth` and `tlsAuthWithCACert`: Define whether TLS authentication is enabled (`false`).
- **Secure JSON Data**: Contains sensitive data that will be encrypted:
    - TLS-related certificates and keys (`tlsCACert`, `tlsClientCert`, `tlsClientKey`).
- **Version**: Specifies the version of this data source configuration (`version: 1`).
- **Editable**: Determines whether users can edit the data source from the Grafana UI (`editable: true`).

**Summary**
This configuration ensures that any existing `Prometheus` data source in Grafana is removed and then redefined with the specified settings. The new `Prometheus` data source is set as the default and allows user edits while keeping sensitive TLS information secure.

### Adding a datasource to Grafana for Loki

A second Loki datasource can be added to the `datasources.yml` file:

```yaml
- name: Loki
  type: loki
  access: proxy
  orgId: 1
  url: http://loki:3100
  basicAuth: false
  isDefault: false
  jsonData:
    maxLines: 1000
    minTimeRange: null
    timeField: time
  secureJsonData:
    tlsCACert: ""
    tlsClientCert: ""
    tlsClientKey: ""
  version: 1
  editable: true
```

In this example the datasource for Loki has been added in `docker-compose.yml` file.

```yaml
    entrypoint:
      - sh
      - -euc
      - |
        mkdir -p /etc/grafana/provisioning/datasources
        cat <<EOF > /etc/grafana/provisioning/datasources/ds.yaml
        apiVersion: 1
        datasources:
        - name: Loki
          type: loki
          access: proxy
          orgId: 1
          url: http://loki:3100
          basicAuth: false
          isDefault: false
          version: 1
          editable: false
        EOF
        /run.sh
```



### Grafana Dashboards

This configuration file specifies the Prometheus data source for Grafana.

We also need to create a `dashboards.yml` file in the `provisioning/dashboards` directory.

```yaml
apiVersion: 1

providers:
  # <string> provider name
  - name: 'default'
    # <int> org id. will default to orgId 1 if not specified
    orgId: 1
    # <string, required> name of the dashboard folder. Required
    folder: ''
    # <string> folder UID. will be automatically generated if not specified
    folderUid: ''
    # <string, required> provider type. Required
    type: file
    # <bool> disable dashboard deletion
    disableDeletion: false
    # <bool> enable dashboard editing
    editable: true
    # <int> how often Grafana will scan for changed dashboards
    updateIntervalSeconds: 10
    options:
      path: /etc/grafana/provisioning/dashboards
```

This configuration file specifies the location of the dashboards that Grafana should load.



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

  <configuration>

    <conversionRule conversionWord="applicationName" class="org.springframework.boot.logging.logback.ApplicationNameConverter"/>
    <conversionRule conversionWord="clr" class="org.springframework.boot.logging.logback.ColorConverter"/>
    <conversionRule conversionWord="correlationId" class="org.springframework.boot.logging.logback.CorrelationIdConverter"/>
    <conversionRule conversionWord="esb" class="org.springframework.boot.logging.logback.EnclosedInSquareBracketsConverter" />
    <conversionRule conversionWord="wex" class="org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter" />
    <conversionRule conversionWord="wEx" class="org.springframework.boot.logging.logback.ExtendedWhitespaceThrowableProxyConverter" />

    <property name="CONSOLE_LOG_PATTERN" value="${CONSOLE_LOG_PATTERN:-%clr(%d{${LOG_DATEFORMAT_PATTERN:-yyyy-MM-dd'T'HH:mm:ss.SSSXXX}}){faint} %clr(${LOG_LEVEL_PATTERN:-%5p}){} %clr(${PID:-}){magenta} %clr(--- %esb(){APPLICATION_NAME}%esb{APPLICATION_GROUP}[%15.15t] ${LOG_CORRELATION_PATTERN:-}){faint}%clr(%-40.40logger{39}){cyan} %clr(:){faint} %m%n${LOG_EXCEPTION_CONVERSION_WORD:-%wEx}}"/>
    <property name="CONSOLE_LOG_CHARSET" value="${CONSOLE_LOG_CHARSET:-${file.encoding:-UTF-8}}"/>
    <property name="CONSOLE_LOG_THRESHOLD" value="${CONSOLE_LOG_THRESHOLD:-TRACE}"/>
    <property name="CONSOLE_LOG_STRUCTURED_FORMAT" value="${CONSOLE_LOG_STRUCTURED_FORMAT:-}"/>
    <property name="FILE_LOG_PATTERN" value="${FILE_LOG_PATTERN:-%d{${LOG_DATEFORMAT_PATTERN:-yyyy-MM-dd'T'HH:mm:ss.SSSXXX}} ${LOG_LEVEL_PATTERN:-%5p} ${PID:-} --- %esb(){APPLICATION_NAME}%esb{APPLICATION_GROUP}[%t] ${LOG_CORRELATION_PATTERN:-}%-40.40logger{39} : %m%n${LOG_EXCEPTION_CONVERSION_WORD:-%wEx}}"/>
    <property name="FILE_LOG_CHARSET" value="${FILE_LOG_CHARSET:-${file.encoding:-UTF-8}}"/>
    <property name="FILE_LOG_THRESHOLD" value="${FILE_LOG_THRESHOLD:-TRACE}"/>
    <property name="FILE_LOG_STRUCTURED_FORMAT" value="${FILE_LOG_STRUCTURED_FORMAT:-}"/>

    <logger name="org.apache.catalina.startup.DigesterFactory" level="ERROR"/>
    <logger name="org.apache.catalina.util.LifecycleBase" level="ERROR"/>
    <logger name="org.apache.coyote.http11.Http11NioProtocol" level="WARN"/>
    <logger name="org.apache.sshd.common.util.SecurityUtils" level="WARN"/>
    <logger name="org.apache.tomcat.util.net.NioSelectorPool" level="WARN"/>
    <logger name="org.eclipse.jetty.util.component.AbstractLifeCycle" level="ERROR"/>
    <logger name="org.hibernate.validator.internal.util.Version" level="WARN"/>
    <logger name="org.springframework.boot.actuate.endpoint.jmx" level="WARN"/>


    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
      <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
        <level>${CONSOLE_LOG_THRESHOLD}</level>
      </filter>
      <encoder>
        <pattern>${CONSOLE_LOG_PATTERN}</pattern>
        <charset>${CONSOLE_LOG_CHARSET}</charset>
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

The `LabelMarker` object is a part of the `loki4j` library.


With the library `loki-logging-spring-boot-starter` we can also send logs to Loki from a Spring Boot application.


```xml
<dependency>
  <groupId>com.github.piomin</groupId>
  <artifactId>loki-logging-spring-boot-starter</artifactId>
  <version>2.0.3</version>
</dependency>
```

By default, the library is enabled, but tries to locate Logback configuration inside your application 
to settings for Logstash appender. 
If such appender won’t be found, the library uses Spring Boot default logging configuration, 
which does not include Logstash appender. 
To force it use auto-configured appender definition inside library we have to set property `logging.logstash.enabled` to true.

```yaml
logging.logstash:
  enabled: true
  url: localhost:3100
```
