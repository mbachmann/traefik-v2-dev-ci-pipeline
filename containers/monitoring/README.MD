# Monitoring with Docker, Prometheus, Grafana, Loki, Promtail and cAdvisor

Monitoring for systems and containers comes in a variety of ways.
One of the most used ways is using Prometheus with Node Exporter and cAdvisor
to collect all types of metrics.
And Grafana to make dashboards to show those metrics.

Metrics alone can’t always reveal errors or issues within your systems.
By centralizing your logging, you can send log files to Loki and use Grafana
for visualization and searching,
providing a comprehensive view of your application’s and potential problems.


## Logging with Loki and Promtail

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

```shell
docker --force-recreate
```
